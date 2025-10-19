//
//  SampleDataHelper.swift
//  LitRev
//
//  Helper to create sample data for testing
//

import Foundation
import CoreData
import UIKit

class SampleDataHelper {
    
    static func createSampleDataIfNeeded(context: NSManagedObjectContext) {
        let defaults = UserDefaults.standard
        let hasSampleData = defaults.bool(forKey: "hasSampleData")
        
        // Only create sample data on first launch
        guard !hasSampleData else { return }
        
        print("Creating sample data...")
        
        // Create sample project
        let project = Project(context: context)
        project.id = UUID()
        project.name = "Cognitive Load in HCI"
        project.researchQuestion = "How does working memory capacity affect multitasking performance in knowledge workers?"
        project.createdAt = Date().addingTimeInterval(-2 * 24 * 60 * 60) // 2 days ago
        project.lastModified = Date()
        
        // Copy sample PDF to documents folder
        if let pdfURL = copySamplePDFToDocuments(projectID: project.id!.uuidString) {
            // Create source from the PDF
            let source = Source(context: context)
            source.id = UUID()
            source.title = "The 2 Sigma Problem: The Search for Methods of Group Instruction as Effective as One-to-One Tutoring"
            source.authors = "Bloom, Benjamin S."
            source.year = 1984
            source.journal = "Educational Researcher"
            source.dateAdded = Date()
            source.project = project
            source.filePath = pdfURL.path
            source.fileName = pdfURL.lastPathComponent
            
            // Generate APA reference
            source.apaReference = "Bloom, B. S. (1984). The 2 Sigma Problem: The Search for Methods of Group Instruction as Effective as One-to-One Tutoring. Educational Researcher, 13(6), 4-16."
            
            // Create some sample excerpts
            createSampleExcerpts(for: source, in: project, context: context)
        }
        
        // Create sample notes with research question
        createSampleNotes(for: project)
        
        do {
            try context.save()
            defaults.set(true, forKey: "hasSampleData")
            print("Sample data created successfully!")
        } catch {
            print("Error creating sample data: \(error.localizedDescription)")
        }
    }
    
    private static func copySamplePDFToDocuments(projectID: String) -> URL? {
        // Try multiple locations for the sample PDF
        let possibleLocations = [
            Bundle.main.url(forResource: "bloom-two-sigma", withExtension: "pdf", subdirectory: "SampleData"),
            Bundle.main.url(forResource: "bloom-two-sigma", withExtension: "pdf"),
            Bundle.main.resourceURL?.appendingPathComponent("SampleData/bloom-two-sigma.pdf")
        ]
        
        var bundlePDFURL: URL?
        for location in possibleLocations {
            if let url = location, FileManager.default.fileExists(atPath: url.path) {
                bundlePDFURL = url
                print("✅ Found PDF at: \(url.path)")
                break
            }
        }
        
        guard let pdfURL = bundlePDFURL else {
            print("❌ Sample PDF not found in bundle")
            print("📂 Searched locations:")
            for location in possibleLocations {
                print("   - \(location?.path ?? "nil")")
            }
            
            // List all resources in bundle
            if let resourcePath = Bundle.main.resourcePath {
                print("📦 Bundle resources:")
                if let contents = try? FileManager.default.contentsOfDirectory(atPath: resourcePath) {
                    for item in contents.prefix(10) {
                        print("   - \(item)")
                    }
                }
            }
            return nil
        }
        
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Could not get documents directory")
            return nil
        }
        
        let projectFolder = documentsURL
            .appendingPathComponent("Projects")
            .appendingPathComponent(projectID)
        
        do {
            try fileManager.createDirectory(at: projectFolder, withIntermediateDirectories: true)
            print("📁 Created project folder: \(projectFolder.path)")
            
            let destinationURL = projectFolder.appendingPathComponent("bloom-two-sigma.pdf")
            
            // Remove if exists
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
                print("🗑️ Removed existing PDF")
            }
            
            try fileManager.copyItem(at: pdfURL, to: destinationURL)
            
            print("✅ PDF copied to: \(destinationURL.path)")
            
            // Verify file was copied
            if fileManager.fileExists(atPath: destinationURL.path) {
                let attributes = try? fileManager.attributesOfItem(atPath: destinationURL.path)
                let fileSize = attributes?[.size] as? Int64 ?? 0
                print("📄 File size: \(fileSize) bytes")
            }
            
            return destinationURL
        } catch {
            print("❌ Error copying PDF: \(error.localizedDescription)")
            return nil
        }
    }
    
    private static func createSampleExcerpts(for source: Source, in project: Project, context: NSManagedObjectContext) {
        // Sample excerpt 1
        let excerpt1 = Excerpt(context: context)
        excerpt1.id = UUID()
        excerpt1.content = "Most striking were the differences in final achievement measures under the three conditions. Using the standard deviation (sigma) of the control (conventional) class, it was typically found that the average student under tutoring was about two standard deviations above the average of the control class (the average tutored student was above 98% of the students in the control class)."
        excerpt1.pageNumber = "1"
        excerpt1.tags = "Key Finding, Statistics"
        excerpt1.createdAt = Date().addingTimeInterval(-24 * 60 * 60)
        excerpt1.source = source
        excerpt1.project = project
        
        // Sample excerpt 2
        let excerpt2 = Excerpt(context: context)
        excerpt2.id = UUID()
        excerpt2.content = "The tutoring process demonstrates that most of the students do have the potential to reach this high level of learning. I believe an important task of research and instruction is to seek ways of accomplishing this under more practical and realistic conditions than the one-to-one tutoring, which is too costly for most societies to bear on a large scale."
        excerpt2.pageNumber = "1"
        excerpt2.tags = "Research Question, Practical Application"
        excerpt2.createdAt = Date().addingTimeInterval(-12 * 60 * 60)
        excerpt2.source = source
        excerpt2.project = project
        
        // Sample excerpt 3 with note
        let excerpt3 = Excerpt(context: context)
        excerpt3.id = UUID()
        excerpt3.content = "Can researchers and teachers devise teaching-learning conditions that will enable the majority of students under group instruction to attain levels of achievement that can at present be reached only under good tutoring conditions?\n\n📝 Note: This directly relates to our research on cognitive load and interface design. Could AI tutoring systems achieve similar results?"
        excerpt3.pageNumber = "2"
        excerpt3.tags = "Question, Connection to HCI"
        excerpt3.createdAt = Date().addingTimeInterval(-6 * 60 * 60)
        excerpt3.source = source
        excerpt3.project = project
    }
    
    private static func createSampleNotes(for project: Project) {
        // Create initial notes with research question
        let initialText = NSMutableAttributedString()
        
        // Research Question header
        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let header = NSAttributedString(string: "Research Question\n", attributes: headerAttrs)
        initialText.append(header)
        
        // Research question text
        let questionAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Georgia", size: 17) ?? UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.label
        ]
        let question = NSAttributedString(
            string: project.researchQuestion ?? "" + "\n\n",
            attributes: questionAttrs
        )
        initialText.append(question)
        
        // Add some sample notes
        let notesAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Georgia", size: 16) ?? UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.label
        ]
        
        let sampleNotes = NSAttributedString(
            string: """
            1. Excerpt from "The Role of Working Memory in Multitasking Performance"
            
            Through a series of controlled experiments with 156 participants, we demonstrate that individuals with higher working memory capacity show significantly better performance when switching between complex cognitive tasks.
            
            2. My thoughts
            
            This connects to Kahneman's concept of cognitive load. Could working memory capacity be the limiting factor in interface design?
            
            3. Excerpt from "The Role of Working Memory in Multitasking Performance"
            
            Working memory, defined as the cognitive system responsible for temporarily holding and manipulating information, has been shown to correlate with various cognitive abilities.
            
            """,
            attributes: notesAttrs
        )
        initialText.append(sampleNotes)
        
        // Save as RTF data
        if let rtfData = try? initialText.data(
            from: NSRange(location: 0, length: initialText.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
        ) {
            project.notesData = rtfData
        }
    }
}

