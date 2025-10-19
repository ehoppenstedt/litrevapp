//
//  APAReferenceGenerator.swift
//  LitRev
//
//  Generates APA-style references from metadata
//

import Foundation

class APAReferenceGenerator {
    
    /// Generate APA reference from source metadata
    static func generate(
        authors: String?,
        year: Int32?,
        title: String?,
        journal: String?,
        doi: String?
    ) -> String {
        var parts: [String] = []
        
        // Authors (Last, F. M., & Last, F. M.)
        if let authors = authors, !authors.isEmpty {
            parts.append(formatAuthors(authors))
        } else {
            parts.append("[Author unknown]")
        }
        
        // Year (2024) or (n.d.)
        if let year = year, year > 0 {
            parts.append("(\(year)).")
        } else {
            parts.append("(n.d.).")
        }
        
        // Title (italicized - we'll use plain text)
        if let title = title, !title.isEmpty {
            parts.append("\(title).")
        }
        
        // Journal (italicized - we'll use plain text)
        if let journal = journal, !journal.isEmpty {
            parts.append("\(journal).")
        }
        
        // DOI
        if let doi = doi, !doi.isEmpty {
            parts.append("https://doi.org/\(doi)")
        }
        
        return parts.joined(separator: " ")
    }
    
    /// Format authors for APA style
    /// Handles various input formats and converts to APA style
    private static func formatAuthors(_ authors: String) -> String {
        // Split by common delimiters
        let separators = [",", ";", " and ", " & "]
        var authorList = [authors]
        
        for separator in separators {
            authorList = authorList.flatMap { $0.components(separatedBy: separator) }
        }
        
        // Clean up author names
        let cleanedAuthors = authorList
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        if cleanedAuthors.isEmpty {
            return "[Author unknown]"
        }
        
        // Format based on number of authors
        switch cleanedAuthors.count {
        case 1:
            return formatSingleAuthor(cleanedAuthors[0])
        case 2:
            return "\(formatSingleAuthor(cleanedAuthors[0])) & \(formatSingleAuthor(cleanedAuthors[1]))"
        case 3...20:
            let formatted = cleanedAuthors.prefix(cleanedAuthors.count - 1).map { formatSingleAuthor($0) }
            return formatted.joined(separator: ", ") + ", & " + formatSingleAuthor(cleanedAuthors.last!)
        default: // More than 20 authors
            let formatted = cleanedAuthors.prefix(19).map { formatSingleAuthor($0) }
            return formatted.joined(separator: ", ") + ", ... " + formatSingleAuthor(cleanedAuthors.last!)
        }
    }
    
    /// Format a single author name
    /// Tries to handle various formats (Last, First; First Last; etc.)
    private static func formatSingleAuthor(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If already in "Last, F." format, return as-is
        if trimmed.contains(",") {
            return trimmed
        }
        
        // Split into parts
        let parts = trimmed.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        
        guard !parts.isEmpty else {
            return trimmed
        }
        
        // Assume last part is last name
        if parts.count == 1 {
            return parts[0]
        } else if parts.count == 2 {
            // First Last -> Last, F.
            let initial = String(parts[0].prefix(1))
            return "\(parts[1]), \(initial)."
        } else {
            // First Middle Last -> Last, F. M.
            let lastName = parts.last!
            let initials = parts.dropLast().map { String($0.prefix(1)) + "." }.joined(separator: " ")
            return "\(lastName), \(initials)"
        }
    }
}

