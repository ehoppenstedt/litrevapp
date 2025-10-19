//
//  ProjectsListView.swift
//  LitRev
//
//  Main screen showing list of research projects
//

import SwiftUI
import CoreData
import UIKit

struct ProjectsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.lastModified, ascending: false)],
        animation: .default)
    private var projects: FetchedResults<Project>
    
    @State private var showingNewProjectSheet = false
    @State private var selectedProject: Project?
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // SIDEBAR: Lista de proyectos
            List(selection: $selectedProject) {
                Section {
                    Button(action: { showingNewProjectSheet = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.accentColor)
                            Text("New Project")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color(.systemBackground))
                }
                
                Section {
                    if projects.isEmpty {
                        Text("No projects yet")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(projects) { project in
                            ProjectSidebarRow(project: project)
                                .tag(project)
                        }
                        .onDelete(perform: deleteProjects)
                    }
                } header: {
                    Text("Projects")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("LitRev")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
        } detail: {
            if let project = selectedProject {
                ProjectDetailView(project: project)
            } else {
                // Empty state when no project is selected
                VStack(spacing: 20) {
                    Image(systemName: "folder.badge.questionmark")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("Select a project to begin")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("or create a new one")
                        .font(.body)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            }
        }
        .sheet(isPresented: $showingNewProjectSheet) {
            NewProjectSheet(isPresented: $showingNewProjectSheet, selectedProject: $selectedProject)
        }
        .onAppear {
            // Select first project if available and nothing is selected
            if selectedProject == nil && !projects.isEmpty {
                selectedProject = projects.first
            }
        }
    }
    
    private func deleteProjects(at offsets: IndexSet) {
        for index in offsets {
            let project = projects[index]
            viewContext.delete(project)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error deleting project: \(error.localizedDescription)")
        }
    }
}

struct ProjectSidebarRow: View {
    @ObservedObject var project: Project
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "folder.fill")
                .font(.system(size: 20))
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name ?? "Untitled Project")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(formatDate(project.lastModified ?? Date()))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let days = calendar.dateComponents([.day], from: date, to: now).day ?? 0
            return "\(days) days ago"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .month) {
            let weeks = calendar.dateComponents([.weekOfYear], from: date, to: now).weekOfYear ?? 0
            return "\(weeks) week\(weeks == 1 ? "" : "s") ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

struct ProjectRowView: View {
    @ObservedObject var project: Project
    
    var body: some View {
        HStack(spacing: 16) {
            // Folder Icon
            Image(systemName: "folder.fill")
                .font(.system(size: 32))
                .foregroundColor(.accentColor)
                .frame(width: 48, height: 48)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(project.name ?? "Untitled Project")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(formatDate(project.lastModified ?? Date()))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Today at \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let days = calendar.dateComponents([.day], from: date, to: now).day ?? 0
            return "\(days) days ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

struct EmptyProjectsView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 72))
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text("No Projects Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Create your first research project to start organizing your literature review.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            
            Spacer()
        }
        .padding(40)
    }
}

struct NewProjectSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    @Binding var selectedProject: Project?
    
    @State private var projectName = ""
    @State private var researchQuestion = ""
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Project Name", text: $projectName)
                        .font(.body)
                        .focused($isNameFieldFocused)
                    
                    TextField("Research Question", text: $researchQuestion, axis: .vertical)
                        .font(.body)
                        .lineLimit(3...6)
                } header: {
                    Text("PROJECT DETAILS")
                } footer: {
                    Text("Choose a descriptive name for your research project (e.g., \"AI Ethics Review\", \"Cognitive Load in HCI\") and define your main research question.")
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createProject()
                    }
                    .disabled(projectName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                isNameFieldFocused = true
            }
        }
    }
    
    private func createProject() {
        let newProject = Project(context: viewContext)
        newProject.id = UUID()
        newProject.name = projectName.trimmingCharacters(in: .whitespaces)
        
        let trimmedQuestion = researchQuestion.trimmingCharacters(in: .whitespaces)
        newProject.researchQuestion = trimmedQuestion.isEmpty ? nil : trimmedQuestion
        newProject.createdAt = Date()
        newProject.lastModified = Date()
        
        // Initialize notesData with formatted research question
        if !trimmedQuestion.isEmpty {
            let initialText = NSMutableAttributedString()
            
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
            let question = NSAttributedString(string: trimmedQuestion + "\n\n", attributes: questionAttrs)
            initialText.append(question)
            
            // Add placeholder for notes
            let notesAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label
            ]
            let notesPlaceholder = NSAttributedString(string: "", attributes: notesAttrs)
            initialText.append(notesPlaceholder)
            
            // Save to notesData
            if let data = try? initialText.data(
                from: NSRange(location: 0, length: initialText.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
            ) {
                newProject.notesData = data
                print("✅ Initialized notesData with research question")
            }
        }
        
        do {
            try viewContext.save()
            selectedProject = newProject  // Auto-select the new project
            isPresented = false
            print("✅ Project created: \(newProject.name ?? "")")
        } catch {
            print("❌ Error creating project: \(error.localizedDescription)")
        }
    }
}

#Preview("Projects List with Data") {
    let context = DataController.preview.container.viewContext
    
    // Create sample projects
    for i in 1...3 {
        let project = Project(context: context)
        project.id = UUID()
        project.name = ["Cognitive Load in HCI", "Machine Learning Ethics", "Attention Mechanisms"][i-1]
        project.createdAt = Date().addingTimeInterval(-Double(i) * 86400 * 7)
        project.lastModified = Date().addingTimeInterval(-Double(i) * 86400)
    }
    
    return ProjectsListView()
        .environment(\.managedObjectContext, context)
}

#Preview("Empty Projects List") {
    ProjectsListView()
        .environment(\.managedObjectContext, DataController.preview.container.viewContext)
}

