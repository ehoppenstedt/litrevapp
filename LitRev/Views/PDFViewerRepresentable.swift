//
//  PDFViewerRepresentable.swift
//  LitRev
//
//  UIKit wrapper for PDFView with annotation support
//

import SwiftUI
import PDFKit

struct PDFViewerRepresentable: UIViewRepresentable {
    let document: PDFDocument
    @Binding var currentPage: Int
    @Binding var totalPages: Int
    @Binding var selectedText: String?
    @Binding var annotationMode: PDFReaderView.AnnotationMode
    
    let onTextSelected: (String, CGRect) -> Void
    let onAreaSelected: (CGRect) -> Void
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = UIColor.systemGroupedBackground
        
        // Enable text selection
        pdfView.isUserInteractionEnabled = true
        
        // Store pdfView in coordinator
        context.coordinator.pdfView = pdfView
        
        // Add notification observers
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged(_:)),
            name: .PDFViewPageChanged,
            object: pdfView
        )
        
        // Add notification for text selection
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.handleSelectionChanged(_:)),
            name: .PDFViewSelectionChanged,
            object: pdfView
        )
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // Update page if changed externally
        if let page = document.page(at: currentPage),
           pdfView.currentPage != page {
            pdfView.go(to: page)
        }
        
        // Update annotation mode
        context.coordinator.annotationMode = annotationMode
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            currentPage: $currentPage,
            totalPages: $totalPages,
            selectedText: $selectedText,
            annotationMode: $annotationMode,
            onTextSelected: onTextSelected,
            onAreaSelected: onAreaSelected
        )
    }
    
    class Coordinator: NSObject {
        @Binding var currentPage: Int
        @Binding var totalPages: Int
        @Binding var selectedText: String?
        @Binding var annotationMode: PDFReaderView.AnnotationMode
        
        let onTextSelected: (String, CGRect) -> Void
        let onAreaSelected: (CGRect) -> Void
        
        weak var pdfView: PDFView?
        
        init(
            currentPage: Binding<Int>,
            totalPages: Binding<Int>,
            selectedText: Binding<String?>,
            annotationMode: Binding<PDFReaderView.AnnotationMode>,
            onTextSelected: @escaping (String, CGRect) -> Void,
            onAreaSelected: @escaping (CGRect) -> Void
        ) {
            _currentPage = currentPage
            _totalPages = totalPages
            _selectedText = selectedText
            _annotationMode = annotationMode
            self.onTextSelected = onTextSelected
            self.onAreaSelected = onAreaSelected
        }
        
        @objc func pageChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView,
                  let currentPDFPage = pdfView.currentPage,
                  let document = pdfView.document else {
                return
            }
            
            let pageIndex = document.index(for: currentPDFPage)
            guard pageIndex != NSNotFound else { return }
            
            DispatchQueue.main.async {
                self.currentPage = pageIndex
            }
        }
        
        @objc func handleSelectionChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView,
                  let selection = pdfView.currentSelection else {
                return
            }
            
            let selectedString = selection.string ?? ""
            guard !selectedString.isEmpty else { return }
            
            // Only process if in highlight or note mode
            guard annotationMode == .highlight || annotationMode == .note else {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.selectedText = selectedString
                
                // Get the bounds of the selection
                if let page = selection.pages.first {
                    let bounds = selection.bounds(for: page)
                    
                    // If in highlight mode, add visual highlight and trigger save
                    if self.annotationMode == .highlight {
                        self.addHighlight(selection: selection, page: page)
                    }
                    
                    self.onTextSelected(selectedString, bounds)
                }
                
                // Clear selection after processing
                pdfView.clearSelection()
            }
        }
        
        private func addHighlight(selection: PDFSelection, page: PDFPage) {
            // Create highlight annotation
            let bounds = selection.bounds(for: page)
            let highlight = PDFAnnotation(bounds: bounds, forType: .highlight, withProperties: nil)
            highlight.color = UIColor.yellow.withAlphaComponent(0.5)
            
            page.addAnnotation(highlight)
        }
    }
}

