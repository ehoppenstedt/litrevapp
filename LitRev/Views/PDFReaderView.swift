//
//  PDFReaderView.swift
//  LitRev
//
//  PDF document reader with annotation capabilities
//

import SwiftUI
import PDFKit
import CoreData

struct PDFReaderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var source: Source
    @ObservedObject var project: Project
    
    @State private var pdfDocument: PDFDocument?
    @State private var currentPage: Int = 0
    @State private var totalPages: Int = 0
    @State private var isLoading = true
    @State private var isHighlightMode = false
    @State private var showToastMessage = false
    @State private var toastMessage = ""
    @State private var showInstructions = false
    
    enum AnnotationMode {
        case none
        case highlight
        case areaClip
        case note
    }
    
    var annotationMode: AnnotationMode {
        isHighlightMode ? .highlight : .none
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top Toolbar - Simplified
                HStack(spacing: 16) {
                    // Back button
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17))
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                            // Highlight mode toggle
                            if !isLoading && pdfDocument != nil {
                                Button(action: { 
                                    isHighlightMode.toggle()
                                    // Show instructions when enabling highlight mode
                                    if isHighlightMode {
                                        showInstructions = true
                                        // Auto-hide after 4 seconds
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                            withAnimation {
                                                showInstructions = false
                                            }
                                        }
                                    } else {
                                        showInstructions = false
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: isHighlightMode ? "pencil.tip.crop.circle.fill" : "highlighter")
                                            .font(.system(size: 16))
                                        Text(isHighlightMode ? "Highlighting Active" : "Enable Highlight")
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                    .foregroundColor(isHighlightMode ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(isHighlightMode ? Color.yellow : Color(.systemGray5))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                    
                    Spacer()
                    
                    // Page indicator
                    if !isLoading && totalPages > 0 {
                        Text("Page \(currentPage + 1) of \(totalPages)")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(.separator)),
                    alignment: .bottom
                )
                
                // PDF Viewer
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Loading document...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let document = pdfDocument {
                            ZStack {
                                PencilEnabledPDFViewer(
                                    document: document,
                                    currentPage: $currentPage,
                                    totalPages: $totalPages,
                                    isHighlightMode: $isHighlightMode,
                                    onTextSelected: { text in
                                        handleTextSelection(text: text)
                                    }
                                )
                                
                                // Instruction overlay when highlight mode is first enabled
                                if showInstructions {
                                    VStack {
                                        HStack(spacing: 12) {
                                            Image(systemName: "hand.tap.fill")
                                                .foregroundColor(.blue)
                                                .font(.system(size: 20))
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Tap and hold to select text")
                                                    .font(.system(size: 15, weight: .semibold))
                                                Text("Selected text will be highlighted and saved")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(16)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(12)
                                        .shadow(radius: 8)
                                        Spacer()
                                    }
                                    .padding(.top, 80)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                }
                            }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        
                        Text("Unable to load document")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        if let fileName = source.fileName {
                            Text(fileName)
                                .font(.caption)
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            
            // Toast notification
            if showToastMessage {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text(toastMessage)
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .medium))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color.green)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .padding(.bottom, 80)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            loadDocument()
        }
    }
    
    private func loadDocument() {
        guard let filePath = source.filePath else {
            print("❌ No file path for source")
            isLoading = false
            return
        }
        
        print("📂 Loading document from: \(filePath)")
        let fileURL = URL(fileURLWithPath: filePath)
        
        // Check if file exists
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: filePath) {
            print("❌ File does not exist at path: \(filePath)")
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let document = PDFDocument(url: fileURL) {
                print("✅ PDF loaded successfully. Pages: \(document.pageCount)")
                DispatchQueue.main.async {
                    self.pdfDocument = document
                    self.totalPages = document.pageCount
                    self.isLoading = false
                }
            } else {
                print("❌ Failed to create PDFDocument from URL")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func handleTextSelection(text: String) {
        guard !text.isEmpty else { return }
        
        // Hide instructions after first successful selection
        if showInstructions {
            withAnimation {
                showInstructions = false
            }
        }
        
        // Create excerpt
        let excerpt = Excerpt(context: viewContext)
        excerpt.id = UUID()
        excerpt.content = text
        excerpt.pageNumber = "\(currentPage + 1)"
        excerpt.createdAt = Date()
        excerpt.source = source
        excerpt.project = project
        
        do {
            try viewContext.save()
            project.lastModified = Date()
            try viewContext.save()
            
            showToast("✓ Saved to Notes & Quotes")
            print("✅ Highlight saved: \(text.prefix(50))...")
        } catch {
            print("❌ Error saving highlight: \(error.localizedDescription)")
            showToast("Failed to save")
        }
    }
    
    private func showToast(_ message: String) {
        toastMessage = message
        withAnimation {
            showToastMessage = true
        }
        
        // Hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showToastMessage = false
            }
        }
    }
}
