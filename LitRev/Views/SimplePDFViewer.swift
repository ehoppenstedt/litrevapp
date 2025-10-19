//
//  SimplePDFViewer.swift
//  LitRev
//
//  Simplified PDF viewer with text selection
//

import SwiftUI
import PDFKit

struct SimplePDFViewer: UIViewRepresentable {
    let document: PDFDocument
    @Binding var currentPage: Int
    @Binding var totalPages: Int
    @Binding var isHighlightMode: Bool
    let onTextSelected: (String) -> Void
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .systemGroupedBackground
        pdfView.isUserInteractionEnabled = true
        
        context.coordinator.pdfView = pdfView
        
        // Page change notification
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged(_:)),
            name: .PDFViewPageChanged,
            object: pdfView
        )
        
        // Selection change notification
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.selectionChanged(_:)),
            name: .PDFViewSelectionChanged,
            object: pdfView
        )
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // Update page if changed
        if let page = document.page(at: currentPage),
           pdfView.currentPage != page {
            pdfView.go(to: page)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            currentPage: $currentPage,
            isHighlightMode: $isHighlightMode,
            onTextSelected: onTextSelected
        )
    }
    
    class Coordinator: NSObject {
        @Binding var currentPage: Int
        @Binding var isHighlightMode: Bool
        let onTextSelected: (String) -> Void
        weak var pdfView: PDFView?
        
        init(
            currentPage: Binding<Int>,
            isHighlightMode: Binding<Bool>,
            onTextSelected: @escaping (String) -> Void
        ) {
            _currentPage = currentPage
            _isHighlightMode = isHighlightMode
            self.onTextSelected = onTextSelected
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
        
        @objc func selectionChanged(_ notification: Notification) {
            guard isHighlightMode else { return }
            
            guard let pdfView = notification.object as? PDFView,
                  let selection = pdfView.currentSelection else {
                return
            }
            
            let text = selection.string ?? ""
            guard !text.isEmpty else { return }
            
            // Add yellow highlight annotation
            if let page = selection.pages.first {
                let bounds = selection.bounds(for: page)
                let highlight = PDFAnnotation(bounds: bounds, forType: .highlight, withProperties: nil)
                highlight.color = UIColor.yellow.withAlphaComponent(0.5)
                page.addAnnotation(highlight)
            }
            
            // Notify selection
            DispatchQueue.main.async { [weak self] in
                self?.onTextSelected(text)
                pdfView.clearSelection()
            }
        }
    }
}

