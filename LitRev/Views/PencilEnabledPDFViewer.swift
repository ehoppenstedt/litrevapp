//
//  PencilEnabledPDFViewer.swift
//  LitRev
//
//  PDF Viewer with Apple Pencil support for highlighting
//

import SwiftUI
import PDFKit
import PencilKit

struct PencilEnabledPDFViewer: UIViewRepresentable {
    let document: PDFDocument
    @Binding var currentPage: Int
    @Binding var totalPages: Int
    @Binding var isHighlightMode: Bool
    let onTextSelected: (String) -> Void
    
    func makeUIView(context: Context) -> PencilPDFContainerView {
        let containerView = PencilPDFContainerView(
            document: document,
            isHighlightMode: isHighlightMode
        )
        
        containerView.coordinator = context.coordinator
        context.coordinator.containerView = containerView
        
        // Add notification observers
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged(_:)),
            name: .PDFViewPageChanged,
            object: containerView.pdfView
        )
        
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.selectionChanged(_:)),
            name: .PDFViewSelectionChanged,
            object: containerView.pdfView
        )
        
        return containerView
    }
    
    func updateUIView(_ containerView: PencilPDFContainerView, context: Context) {
        // Update page if changed
        if let page = document.page(at: currentPage),
           containerView.pdfView.currentPage != page {
            containerView.pdfView.go(to: page)
        }
        
        // Update highlight mode
        containerView.setHighlightMode(isHighlightMode)
        context.coordinator.isHighlightMode = isHighlightMode
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
        weak var containerView: PencilPDFContainerView?
        
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

// MARK: - Container View

class PencilPDFContainerView: UIView, PKCanvasViewDelegate {
    
    let pdfView: PDFView
    let canvasView: PKCanvasView
    var coordinator: PencilEnabledPDFViewer.Coordinator?
    
    private var isHighlightMode: Bool = false
    
    init(document: PDFDocument, isHighlightMode: Bool) {
        self.pdfView = PDFView()
        self.canvasView = PKCanvasView()
        self.isHighlightMode = isHighlightMode
        
        super.init(frame: .zero)
        
        setupPDFView(document: document)
        setupCanvasView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPDFView(document: PDFDocument) {
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .systemGroupedBackground
        pdfView.isUserInteractionEnabled = true
        
        addSubview(pdfView)
    }
    
    private func setupCanvasView() {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.delegate = self
        
        // Configure the drawing tool for highlighting
        let tool = PKInkingTool(.marker, color: .yellow, width: 20)
        canvasView.tool = tool
        
        // Enable drawing only when in highlight mode
        canvasView.isUserInteractionEnabled = isHighlightMode
        canvasView.drawingPolicy = .pencilOnly // Only respond to Apple Pencil
        
        // Allow touches to pass through to PDF when not drawing
        canvasView.isMultipleTouchEnabled = false
        
        addSubview(canvasView)
    }
    
    private func setupLayout() {
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // PDF View fills entire container
            pdfView.topAnchor.constraint(equalTo: topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Canvas View overlays PDF View
            canvasView.topAnchor.constraint(equalTo: topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setHighlightMode(_ enabled: Bool) {
        isHighlightMode = enabled
        
        if enabled {
            // Enable canvas for Apple Pencil drawing
            canvasView.isUserInteractionEnabled = true
            canvasView.alpha = 0.1 // Very subtle, just to show it's active
            
            // Set drawing tool
            let tool = PKInkingTool(.marker, color: .yellow, width: 20)
            canvasView.tool = tool
            
            print("✏️ Highlight mode ENABLED:")
            print("   📱 In Simulator: Use tap-and-hold to select text")
            print("   🖊️ On Real iPad: Use Apple Pencil to draw highlights")
        } else {
            // Disable canvas completely when not in highlight mode
            canvasView.isUserInteractionEnabled = false
            canvasView.alpha = 0.0 // Completely invisible
            
            print("✏️ Highlight mode DISABLED")
        }
    }
    
    // MARK: - PKCanvasViewDelegate
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        // When user finishes drawing, convert strokes to PDF highlights
        processDrawingAsHighlight()
    }
    
    private func processDrawingAsHighlight() {
        guard let currentPage = pdfView.currentPage,
              !canvasView.drawing.strokes.isEmpty else {
            return
        }
        
        // Get the bounds of all strokes
        let drawing = canvasView.drawing
        guard !drawing.bounds.isEmpty else { return }
        
        // Extract text from the highlighted area
        let convertedBounds = convertCanvasBoundsToPDFBounds(drawing.bounds, for: currentPage)
        
        // Create a selection in that area
        if let selection = currentPage.selection(for: convertedBounds) {
            let text = selection.string ?? ""
            
            if !text.isEmpty {
                // Add visual highlight annotation
                let highlight = PDFAnnotation(bounds: convertedBounds, forType: .highlight, withProperties: nil)
                highlight.color = UIColor.yellow.withAlphaComponent(0.5)
                currentPage.addAnnotation(highlight)
                
                // Notify coordinator
                DispatchQueue.main.async { [weak self] in
                    self?.coordinator?.onTextSelected(text)
                }
            }
        }
        
        // Clear the canvas after processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.canvasView.drawing = PKDrawing()
        }
    }
    
    private func convertCanvasBoundsToPDFBounds(_ canvasBounds: CGRect, for page: PDFPage) -> CGRect {
        // Convert canvas coordinates to PDF coordinates
        // This is a simplified conversion - may need adjustment based on zoom/scroll
        let pdfPageBounds = page.bounds(for: .mediaBox)
        
        // Get the conversion ratio
        let pdfViewBounds = pdfView.convert(pdfPageBounds, from: page)
        
        // Convert canvas bounds to PDF bounds
        let convertedRect = pdfView.convert(canvasBounds, to: page)
        
        return convertedRect
    }
}

