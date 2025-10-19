//
//  MetadataExtractor.swift
//  LitRev
//
//  Extracts metadata from document files
//

import Foundation
import PDFKit

struct DocumentMetadata {
    var title: String?
    var authors: String?
    var year: String?
    var keywords: String?
    var journal: String?
    var doi: String?
    var publisher: String?
}

class MetadataExtractor {
    
    /// Extract metadata from a PDF file
    static func extractFromPDF(url: URL) -> DocumentMetadata {
        var metadata = DocumentMetadata()
        
        guard let pdfDocument = PDFDocument(url: url) else {
            // If can't open PDF, use filename as title
            metadata.title = url.deletingPathExtension().lastPathComponent
            return metadata
        }
        
        // Extract PDF metadata
        if let pdfMetadata = pdfDocument.documentAttributes {
            // Title
            if let title = pdfMetadata[PDFDocumentAttribute.titleAttribute] as? String,
               !title.trimmingCharacters(in: .whitespaces).isEmpty {
                metadata.title = cleanString(title)
            }
            
            // Author
            if let author = pdfMetadata[PDFDocumentAttribute.authorAttribute] as? String,
               !author.trimmingCharacters(in: .whitespaces).isEmpty {
                metadata.authors = cleanString(author)
            }
            
            // Keywords
            if let keywords = pdfMetadata[PDFDocumentAttribute.keywordsAttribute] as? String,
               !keywords.trimmingCharacters(in: .whitespaces).isEmpty {
                metadata.keywords = keywords
            }
            
            // Subject (sometimes contains publication info or journal name)
            if let subject = pdfMetadata[PDFDocumentAttribute.subjectAttribute] as? String,
               !subject.trimmingCharacters(in: .whitespaces).isEmpty {
                metadata.journal = cleanString(subject)
                
                // Try to extract year from subject
                if let yearMatch = extractYear(from: subject) {
                    metadata.year = yearMatch
                }
            }
            
            // Producer (sometimes contains publisher info)
            if let producer = pdfMetadata[PDFDocumentAttribute.producerAttribute] as? String,
               !producer.trimmingCharacters(in: .whitespaces).isEmpty {
                metadata.publisher = cleanString(producer)
            }
            
            // Creation/Modification date - extract year if not found yet
            if metadata.year == nil {
                if let creationDate = pdfMetadata[PDFDocumentAttribute.creationDateAttribute] as? Date {
                    let calendar = Calendar.current
                    let year = calendar.component(.year, from: creationDate)
                    // Only use if reasonable (not too old or in the future)
                    if year >= 1900 && year <= Calendar.current.component(.year, from: Date()) {
                        metadata.year = "\(year)"
                    }
                }
            }
        }
        
        // Try to extract from first page text
        if let firstPage = pdfDocument.page(at: 0),
           let pageText = firstPage.string {
            
            // Try to find DOI
            if let doi = extractDOI(from: pageText) {
                metadata.doi = doi
            }
            
            // Try to extract year from text if still not found
            if metadata.year == nil, let year = extractYear(from: pageText) {
                metadata.year = year
            }
            
            // Try to find journal name (common patterns)
            if metadata.journal == nil {
                metadata.journal = extractJournal(from: pageText)
            }
        }
        
        // If no title found, use filename
        if metadata.title == nil || metadata.title?.isEmpty == true {
            metadata.title = url.deletingPathExtension().lastPathComponent
        }
        
        return metadata
    }
    
    /// Extract DOI from text
    private static func extractDOI(from text: String) -> String? {
        // DOI pattern: 10.xxxx/xxxxx
        let pattern = #"10\.\d{4,}/[^\s]+"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
            if let range = Range(match.range, in: text) {
                return String(text[range])
            }
        }
        return nil
    }
    
    /// Extract journal name from text (heuristic)
    private static func extractJournal(from text: String) -> String? {
        // Look for common journal indicators
        let lines = text.components(separatedBy: .newlines)
        for (index, line) in lines.enumerated() where index < 20 { // Check first 20 lines
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Skip if too short or too long
            if trimmed.count < 10 || trimmed.count > 100 {
                continue
            }
            
            // Check for journal keywords
            if trimmed.lowercased().contains("journal") ||
               trimmed.lowercased().contains("proceedings") ||
               trimmed.lowercased().contains("review") ||
               trimmed.lowercased().contains("transactions") {
                return trimmed
            }
        }
        return nil
    }
    
    /// Clean string by removing excessive whitespace
    private static func cleanString(_ string: String) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    /// Extract metadata from other document types
    static func extractFromDocument(url: URL) -> DocumentMetadata {
        var metadata = DocumentMetadata()
        
        // For non-PDF files, use filename as title
        metadata.title = url.deletingPathExtension().lastPathComponent
        
        // Try to extract year from filename
        let filename = url.lastPathComponent
        if let yearMatch = extractYear(from: filename) {
            metadata.year = yearMatch
        }
        
        return metadata
    }
    
    /// Extract 4-digit year from text
    private static func extractYear(from text: String) -> String? {
        let pattern = #"\b(19|20)\d{2}\b"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
            if let range = Range(match.range, in: text) {
                return String(text[range])
            }
        }
        return nil
    }
    
    /// Main extraction method that determines file type
    static func extract(from url: URL) -> DocumentMetadata {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return extractFromPDF(url: url)
        default:
            return extractFromDocument(url: url)
        }
    }
}

