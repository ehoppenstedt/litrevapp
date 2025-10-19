//
//  URLImportView.swift
//  LitRev
//
//  View for importing PDFs from URL
//

import SwiftUI

struct URLImportView: View {
    @Binding var isPresented: Bool
    let onURLSelected: (URL) -> Void
    
    @State private var urlString = ""
    @State private var isDownloading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.accentColor)
                    
                    Text("Import PDF from URL")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter the URL of a PDF document")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("PDF URL")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    TextField("https://example.com/document.pdf", text: $urlString)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disabled(isDownloading)
                    
                    if let error = errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text("The document will be downloaded and stored locally")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
                
                if isDownloading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Downloading PDF...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                }
                
                Spacer()
                
                Button(action: { downloadPDF() }) {
                    HStack {
                        if isDownloading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "arrow.down.circle.fill")
                            Text("Download PDF")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isValidURL && !isDownloading ? Color.accentColor : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .disabled(!isValidURL || isDownloading)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationTitle("Import from URL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .disabled(isDownloading)
                }
            }
        }
    }
    
    private var isValidURL: Bool {
        guard let url = URL(string: urlString) else { return false }
        return url.scheme == "http" || url.scheme == "https"
    }
    
    private func downloadPDF() {
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }
        
        isDownloading = true
        errorMessage = nil
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            DispatchQueue.main.async {
                isDownloading = false
                
                if let error = error {
                    errorMessage = "Download failed: \(error.localizedDescription)"
                    return
                }
                
                guard let localURL = localURL else {
                    errorMessage = "Download failed"
                    return
                }
                
                // Check if it's a PDF
                if let mimeType = response?.mimeType, !mimeType.contains("pdf") {
                    errorMessage = "The URL does not point to a PDF file"
                    return
                }
                
                onURLSelected(localURL)
                isPresented = false
            }
        }
        
        task.resume()
    }
}

