//
//  ProjectDetailView.swift
//  LitRev
//
//  Detail view for a single project showing Notes & Excerpts, Current Source, and List of Sources
//

import SwiftUI
import CoreData

struct ProjectDetailView: View {
    @ObservedObject var project: Project
    @State private var selectedTab: ProjectTab = .notes
    @State private var showingAddSource = false
    @State private var currentSource: Source?
    
    enum ProjectTab: String, CaseIterable {
        case notes = "Notes & Excerpts"
        case currentSource = "Current Source"
        case sources = "List of Sources"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with project name and Add Source button
            HStack {
                Text(project.name ?? "Untitled Project")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { showingAddSource = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Add Source")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            // Tab selector
            HStack(spacing: 0) {
                ForEach(ProjectTab.allCases, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        VStack(spacing: 8) {
                            Text(tab.rawValue)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(selectedTab == tab ? .primary : .secondary)
                            
                            Rectangle()
                                .fill(selectedTab == tab ? Color.accentColor : Color.clear)
                                .frame(height: 3)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 32)
            .background(Color(.systemBackground))
            
            Divider()
            
            // Tab content
            TabView(selection: $selectedTab) {
                NotesExcerptsView(project: project)
                    .tag(ProjectTab.notes)
                
                CurrentSourceView(project: project, selectedSource: $currentSource)
                    .tag(ProjectTab.currentSource)
                
                SourcesListView(project: project, selectedTab: $selectedTab, currentSource: $currentSource)
                    .tag(ProjectTab.sources)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingAddSource) {
            AddSourceSheet(project: project, isPresented: $showingAddSource, selectedTab: $selectedTab, currentSource: $currentSource)
        }
    }
}

struct NotesExcerptsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var project: Project
    @State private var attributedText: NSAttributedString
    @State private var showingTagSheet = false
    
    init(project: Project) {
        self.project = project
        
        // Initialize with stored notes or create default
        if let notesData = project.notesData,
           let savedNotes = try? NSAttributedString(
            data: notesData,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
           ) {
            _attributedText = State(initialValue: savedNotes)
        } else {
            // Create initial formatted text with research question if available
            let initialText = NSMutableAttributedString()
            
            if let researchQuestion = project.researchQuestion, !researchQuestion.isEmpty {
                // Add research question header
                let headerAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let header = NSAttributedString(string: "Research Question\n", attributes: headerAttrs)
                initialText.append(header)
                
                // Add research question text
                let questionAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: "Georgia", size: 17) ?? UIFont.systemFont(ofSize: 17),
                    .foregroundColor: UIColor.label
                ]
                let question = NSAttributedString(string: researchQuestion + "\n\n", attributes: questionAttrs)
                initialText.append(question)
            }
            
            _attributedText = State(initialValue: initialText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Format toolbar
            TextFormatToolbar(
                onBold: { applyBoldToSelection() },
                onItalic: { applyItalicToSelection() },
                onBulletList: { /* TODO */ },
                onHighlight: { /* TODO */ },
                onTag: { showingTagSheet = true }
            )
            
            // Rich text editor
            RichTextEditor(
                attributedText: $attributedText,
                placeholder: "Start writing your notes and excerpts here..."
            )
            .onChange(of: attributedText) { newValue in
                saveNotes(newValue)
            }
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingTagSheet) {
            TagInsertSheet(isPresented: $showingTagSheet) { tagText in
                insertTag(tagText)
            }
        }
    }
    
    private func saveNotes(_ notes: NSAttributedString) {
        do {
            let data = try notes.data(
                from: NSRange(location: 0, length: notes.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
            )
            project.notesData = data
            project.lastModified = Date()
            try viewContext.save()
        } catch {
            print("Error saving notes: \(error.localizedDescription)")
        }
    }
    
    private func applyBoldToSelection() {
        // This will be implemented with UITextView delegate
        // For now, placeholder
    }
    
    private func applyItalicToSelection() {
        // This will be implemented with UITextView delegate
        // For now, placeholder
    }
    
    private func insertTag(_ tag: String) {
        let tagAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.systemBlue,
            .backgroundColor: UIColor.systemBlue.withAlphaComponent(0.1)
        ]
        
        let mutableText = NSMutableAttributedString(attributedString: attributedText)
        let tagString = NSAttributedString(string: " #\(tag) ", attributes: tagAttrs)
        mutableText.append(tagString)
        attributedText = mutableText
    }
}

struct TagInsertSheet: View {
    @Binding var isPresented: Bool
    let onInsert: (String) -> Void
    @State private var tagText = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Tag name", text: $tagText)
                } header: {
                    Text("INSERT TAG")
                }
            }
            .navigationTitle("Add Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Insert") {
                        onInsert(tagText)
                        isPresented = false
                    }
                    .disabled(tagText.isEmpty)
                }
            }
        }
    }
}

struct ExcerptRowView: View {
    @ObservedObject var excerpt: Excerpt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Source info
            if let source = excerpt.source {
                HStack(spacing: 8) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.accentColor)
                    
                    Text(source.title ?? "Unknown Source")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.accentColor)
                    
                    if let pageNumber = excerpt.pageNumber, !pageNumber.isEmpty {
                        Text("• p. \(pageNumber)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let createdAt = excerpt.createdAt {
                        Text(formatDate(createdAt))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Excerpt content
            if let content = excerpt.content, !content.isEmpty {
                Text(content)
                    .font(.system(size: 15, design: .serif))
                    .foregroundColor(.primary)
                    .lineSpacing(4)
            }
            
            // Tags
            if let tags = excerpt.tags, !tags.isEmpty {
                HStack {
                    ForEach(tags.components(separatedBy: ","), id: \.self) { tag in
                        Text(tag.trimmingCharacters(in: .whitespaces))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct CurrentSourceView: View {
    @ObservedObject var project: Project
    @Binding var selectedSource: Source?
    @FetchRequest private var sources: FetchedResults<Source>
    @State private var errorMessage: String?
    
    init(project: Project, selectedSource: Binding<Source?>) {
        self.project = project
        _selectedSource = selectedSource
        let request: NSFetchRequest<Source> = Source.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Source.dateAdded, ascending: false)]
        request.predicate = NSPredicate(format: "project == %@", project)
        _sources = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        Group {
            if let error = errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 64))
                        .foregroundColor(.orange)
                    
                    Text("Error loading source")
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    Text(error)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else if let source = selectedSource ?? sources.first, source.filePath != nil {
                PDFReaderView(source: source, project: project)
                    .onAppear {
                        print("📄 Opening PDF: \(source.fileName ?? "unknown")")
                        print("📍 Path: \(source.filePath ?? "no path")")
                    }
            } else if !sources.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("Select a source with a file")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        // Find first source with a file
                        selectedSource = sources.first(where: { $0.filePath != nil })
                    }) {
                        Text("Open First Source")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("No sources yet")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("Add a source with a document to start reading")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
    }
}

struct SourcesListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var project: Project
    @Binding var selectedTab: ProjectDetailView.ProjectTab
    @Binding var currentSource: Source?
    @FetchRequest private var sources: FetchedResults<Source>
    
    init(project: Project, selectedTab: Binding<ProjectDetailView.ProjectTab>, currentSource: Binding<Source?>) {
        self.project = project
        _selectedTab = selectedTab
        _currentSource = currentSource
        let request: NSFetchRequest<Source> = Source.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Source.dateAdded, ascending: false)]
        request.predicate = NSPredicate(format: "project == %@", project)
        _sources = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        Group {
            if sources.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("No sources yet — tap Add Source to begin.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else {
                List {
                    ForEach(sources) { source in
                        SourceRowView(source: source, project: project)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if source.filePath != nil {
                                    // Set as current source and switch to Current Source tab
                                    currentSource = source
                                    selectedTab = .currentSource
                                    print("📖 Opening source in Current Source tab: \(source.title ?? "Untitled")")
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteSources)
                }
                .listStyle(.plain)
                .background(Color(.systemGroupedBackground))
            }
        }
        .toolbar {
            if !sources.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    private func deleteSources(at offsets: IndexSet) {
        for index in offsets {
            let source = sources[index]
            
            // Delete the PDF file if it exists
            if let filePath = source.filePath {
                let fileURL = URL(fileURLWithPath: filePath)
                try? FileManager.default.removeItem(at: fileURL)
                print("🗑️ Deleted file: \(filePath)")
            }
            
            // Delete excerpts associated with this source
            if let excerpts = source.excerpts as? Set<Excerpt> {
                for excerpt in excerpts {
                    viewContext.delete(excerpt)
                }
                print("🗑️ Deleted \(excerpts.count) excerpts")
            }
            
            // Delete the source from Core Data
            viewContext.delete(source)
            print("🗑️ Deleted source: \(source.title ?? "Untitled")")
        }
        
        do {
            try viewContext.save()
            project.lastModified = Date()
            try viewContext.save()
            print("✅ Source deletion completed")
        } catch {
            print("❌ Error deleting source: \(error.localizedDescription)")
        }
    }
}

struct SourceRowView: View {
    @ObservedObject var source: Source
    @ObservedObject var project: Project
    @State private var showingReader = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(source.title ?? "Untitled")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if let authors = source.authors, !authors.isEmpty {
                        Text(authors)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    if source.year > 0 {
                        Text("Year: \(source.year)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if source.filePath != nil {
                    VStack(spacing: 8) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.accentColor)
                        
                        Text("Open")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                    .padding(12)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            
            if let apaReference = source.apaReference {
                Text(apaReference)
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.top, 4)
            }
            
            if let fileName = source.fileName {
                HStack(spacing: 6) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 11))
                    Text(fileName)
                        .font(.system(size: 12))
                }
                .foregroundColor(.secondary.opacity(0.7))
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct AddSourceSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var project: Project
    @Binding var isPresented: Bool
    @Binding var selectedTab: ProjectDetailView.ProjectTab
    @Binding var currentSource: Source?
    
    @State private var showingDocumentPicker = false
    @State private var showingURLEntry = false
    @State private var selectedFileURL: URL?
    @State private var extractedMetadata: DocumentMetadata?
    
    @State private var title = ""
    @State private var authors = ""
    @State private var year = ""
    @State private var journal = ""
    @State private var doi = ""
    
    var body: some View {
        NavigationView {
            if selectedFileURL == nil {
                // Initial view - Choose import method
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 72))
                        .foregroundColor(.accentColor)
                    
                    Text("Add Source")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Import a document from your device or from a URL")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            showingDocumentPicker = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "folder.badge.plus")
                                    .font(.system(size: 20))
                                Text("Import from Files")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            showingURLEntry = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "link")
                                    .font(.system(size: 20))
                                Text("Import from URL")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .navigationTitle("Add Source")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isPresented = false
                        }
                    }
                }
                .sheet(isPresented: $showingDocumentPicker) {
                    DocumentPicker(isPresented: $showingDocumentPicker) { url in
                        handleDocumentSelection(url: url)
                    }
                }
                .sheet(isPresented: $showingURLEntry) {
                    URLImportView(
                        isPresented: $showingURLEntry,
                        onURLSelected: { url in
                            handleURLSelection(url: url)
                        }
                    )
                }
            } else {
                // Show form with extracted metadata
                MetadataFormView(
                    title: $title,
                    authors: $authors,
                    year: $year,
                    journal: $journal,
                    doi: $doi,
                    fileName: selectedFileURL?.lastPathComponent ?? "",
                    onSave: { addSource() },
                    onCancel: {
                        selectedFileURL = nil
                        title = ""
                        authors = ""
                        year = ""
                        journal = ""
                        doi = ""
                    }
                )
            }
        }
    }
    
    private func handleDocumentSelection(url: URL) {
        // Start accessing security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            print("Failed to access security-scoped resource")
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        processAndSaveDocument(from: url)
    }
    
    private func handleURLSelection(url: URL) {
        // URL is a temporary file from download
        // For URL imports, create source automatically and open reader
        processAndSaveDocumentDirectly(from: url)
    }
    
    private func processAndSaveDocument(from url: URL) {
        // Copy file to app's documents directory
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let projectFolder = documentsURL.appendingPathComponent("Projects").appendingPathComponent(project.id?.uuidString ?? "default")
        
        do {
            try fileManager.createDirectory(at: projectFolder, withIntermediateDirectories: true)
            
            let fileName = url.lastPathComponent.isEmpty ? "document.pdf" : url.lastPathComponent
            let destinationURL = projectFolder.appendingPathComponent(fileName)
            
            // Remove existing file if it exists
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            try fileManager.copyItem(at: url, to: destinationURL)
            
            selectedFileURL = destinationURL
            
            // Extract metadata
            let metadata = MetadataExtractor.extract(from: destinationURL)
            extractedMetadata = metadata
            
            // Pre-fill form with extracted data
            title = metadata.title ?? ""
            authors = metadata.authors ?? ""
            year = metadata.year ?? ""
            journal = metadata.journal ?? ""
            doi = metadata.doi ?? ""
            
            print("📄 Extracted metadata:")
            print("  Title: \(title)")
            print("  Authors: \(authors)")
            print("  Year: \(year)")
            print("  Journal: \(journal)")
            print("  DOI: \(doi)")
            
        } catch {
            print("Error copying file: \(error.localizedDescription)")
        }
    }
    
    private func processAndSaveDocumentDirectly(from url: URL) {
        // Copy file to app's documents directory
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let projectFolder = documentsURL.appendingPathComponent("Projects").appendingPathComponent(project.id?.uuidString ?? "default")
        
        do {
            try fileManager.createDirectory(at: projectFolder, withIntermediateDirectories: true)
            
            let fileName = url.lastPathComponent.isEmpty ? "document.pdf" : url.lastPathComponent
            let destinationURL = projectFolder.appendingPathComponent(fileName)
            
            // Remove existing file if it exists
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            try fileManager.copyItem(at: url, to: destinationURL)
            
            // Extract metadata
            let metadata = MetadataExtractor.extract(from: destinationURL)
            
            // Create source automatically
            let newSource = Source(context: viewContext)
            newSource.id = UUID()
            newSource.title = metadata.title ?? fileName
            newSource.authors = metadata.authors ?? ""
            newSource.year = Int32(metadata.year ?? "") ?? 0
            newSource.journal = metadata.journal
            newSource.doi = metadata.doi
            newSource.dateAdded = Date()
            newSource.project = project
            newSource.filePath = destinationURL.path
            newSource.fileName = fileName
            
            // Generate APA reference
            newSource.apaReference = APAReferenceGenerator.generate(
                authors: metadata.authors,
                year: Int32(metadata.year ?? ""),
                title: metadata.title,
                journal: metadata.journal,
                doi: metadata.doi
            )
            
            print("📚 Created source from URL:")
            print("  Title: \(newSource.title ?? "")")
            print("  APA: \(newSource.apaReference ?? "")")
            
            try viewContext.save()
            project.lastModified = Date()
            try viewContext.save()
            
            // Open in Current Source tab
            currentSource = newSource
            selectedTab = .currentSource
            isPresented = false
            print("📖 Opening source in Current Source tab")
            
        } catch {
            print("❌ Error creating source from URL: \(error.localizedDescription)")
        }
    }
    
    private func addSource() {
        let newSource = Source(context: viewContext)
        newSource.id = UUID()
        newSource.title = title
        newSource.authors = authors
        newSource.year = Int32(year) ?? 0
        newSource.journal = journal.isEmpty ? nil : journal
        newSource.doi = doi.isEmpty ? nil : doi
        newSource.dateAdded = Date()
        newSource.project = project
        
        // Store file path if available
        if let fileURL = selectedFileURL {
            newSource.filePath = fileURL.path
            newSource.fileName = fileURL.lastPathComponent
        }
        
        // Generate APA reference automatically
        newSource.apaReference = APAReferenceGenerator.generate(
            authors: authors.isEmpty ? nil : authors,
            year: Int32(year),
            title: title.isEmpty ? nil : title,
            journal: journal.isEmpty ? nil : journal,
            doi: doi.isEmpty ? nil : doi
        )
        
        print("📚 Generated APA reference: \(newSource.apaReference ?? "none")")
        
        do {
            try viewContext.save()
            project.lastModified = Date()
            try viewContext.save()
            isPresented = false
        } catch {
            print("Error adding source: \(error.localizedDescription)")
        }
    }
}

struct MetadataFormView: View {
    @Binding var title: String
    @Binding var authors: String
    @Binding var year: String
    @Binding var journal: String
    @Binding var doi: String
    
    let fileName: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: "doc.fill")
                        .foregroundColor(.accentColor)
                    Text(fileName)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("IMPORTED FILE")
            }
            
            Section {
                TextField("Title", text: $title)
                TextField("Authors (Last, F., Last, F.)", text: $authors)
                TextField("Year", text: $year)
                    .keyboardType(.numberPad)
                TextField("Journal or Publisher", text: $journal)
                TextField("DOI (optional)", text: $doi)
            } header: {
                Text("SOURCE INFORMATION")
            } footer: {
                Text("Review and edit the extracted information. APA reference will be generated automatically.")
            }
        }
        .navigationTitle("Review Metadata")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") {
                    onCancel()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    onSave()
                }
                .disabled(title.isEmpty || authors.isEmpty)
            }
        }
    }
}

#Preview {
    let context = DataController.preview.container.viewContext
    let project = Project(context: context)
    project.id = UUID()
    project.name = "Cognitive Load in HCI"
    project.createdAt = Date()
    project.lastModified = Date()
    
    return NavigationStack {
        ProjectDetailView(project: project)
            .environment(\.managedObjectContext, context)
    }
}


