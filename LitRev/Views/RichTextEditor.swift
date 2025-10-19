//
//  RichTextEditor.swift
//  LitRev
//
//  Rich text editor wrapper using UITextView
//

import SwiftUI
import UIKit

struct RichTextEditor: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    var placeholder: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont(name: "Georgia", size: 16) ?? UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .systemBackground
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsEditingTextAttributes = true
        
        // Set initial attributed text
        if attributedText.length == 0 {
            textView.text = placeholder
            textView.textColor = .placeholderText
        } else {
            textView.attributedText = attributedText
        }
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        if attributedText.length > 0 && textView.attributedText != attributedText {
            textView.attributedText = attributedText
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = textView.attributedText
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == .placeholderText {
                textView.text = ""
                textView.textColor = .label
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = .placeholderText
            }
        }
    }
}

struct TextFormatToolbar: View {
    let onBold: () -> Void
    let onItalic: () -> Void
    let onBulletList: () -> Void
    let onHighlight: () -> Void
    let onTag: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            FormatButton(icon: "bold", action: onBold)
            FormatButton(icon: "italic", action: onItalic)
            FormatButton(icon: "list.bullet", action: onBulletList)
            FormatButton(icon: "pencil.tip", action: onHighlight)
            FormatButton(icon: "tag", action: onTag)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }
}

struct FormatButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 40, height: 40)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

