# 🚀 LitRev Development Guide

## Quick Start

### Open the Project
```bash
./open-xcode.sh
```
This script will regenerate the Xcode project and open it for you.

Or manually:
```bash
xcodegen generate
open LitRev.xcodeproj
```

---

## 📱 Setting Up iPad Simulator

### Method 1: Using Xcode Menu (Easiest)

1. **Open Xcode** (use `./open-xcode.sh`)
2. Click on the **device selector** in the top toolbar (shows "LitRev > [Current Device]")
3. Choose an iPad simulator from the list:
   - iPad Pro (12.9-inch) (6th generation) ⭐ **Recommended**
   - iPad Air (5th generation)
   - iPad (10th generation)
4. Press **`Cmd + R`** to build and run

### Method 2: Create a New Simulator

1. In Xcode menu: **Window → Devices and Simulators** (`Cmd + Shift + 2`)
2. Click the **"Simulators"** tab
3. Click **"+"** button at the bottom left
4. Configure:
   - **Simulator Name**: "iPad Pro 12.9 Dev" (or your preference)
   - **Device Type**: iPad Pro (12.9-inch) (6th generation)
   - **OS Version**: Latest available (iOS 17+)
5. Click **"Create"**
6. Close the window and select your new simulator from the device selector

---

## 🛠️ Development Workflow

### 1. Make Code Changes
Edit any Swift files in the `LitRev/` directory

### 2. Regenerate Project (if needed)
If you add/remove files or change project structure:
```bash
xcodegen generate
```

### 3. Build & Run
- **`Cmd + R`** - Build and run
- **`Cmd + B`** - Build only
- **`Cmd + .`** - Stop running app

### 4. Debug
- **`Cmd + \`** - Toggle breakpoint on current line
- **`Cmd + Y`** - Activate/deactivate breakpoints
- Use the **Debug Console** at bottom of Xcode to see `print()` statements

---

## 📁 Project Structure

```
LitRev/
├── LitRevApp.swift           # App entry point
├── ContentView.swift          # Root view
├── Views/
│   ├── ProjectsListView.swift      # Projects sidebar
│   ├── ProjectDetailView.swift     # Main project screen with tabs
│   ├── PDFReaderView.swift         # PDF reader with highlight mode
│   ├── PencilEnabledPDFViewer.swift # Apple Pencil integration
│   ├── SimplePDFViewer.swift       # Basic PDF viewer
│   ├── RichTextEditor.swift        # Rich text notes editor
│   └── URLImportView.swift         # URL import dialog
├── Models/
│   ├── DataController.swift        # Core Data stack
│   ├── Project+CoreDataClass.swift
│   ├── Source+CoreDataClass.swift
│   └── Excerpt+CoreDataClass.swift
├── Services/
│   ├── DocumentPicker.swift        # File picker
│   └── MetadataExtractor.swift     # PDF metadata extraction
├── Utilities/
│   ├── APAReferenceGenerator.swift # APA citation generator
│   └── SampleDataHelper.swift      # Sample data for testing
└── SampleData/
    └── bloom-two-sigma.pdf         # Test PDF
```

---

## 🎨 Key Features to Test

### ✅ Project Management
- Create new project
- Add research question
- View/edit/delete projects

### ✅ Source Import
- Import from Files app
- Import from URL
- Automatic metadata extraction
- APA reference generation

### ✅ PDF Reader
- Open PDF documents
- Enable highlight mode
- Text selection highlighting
- **Apple Pencil drawing** (requires real iPad)
- Page navigation
- Back to project

### ✅ Notes & Excerpts
- Rich text editor
- View research question at top
- View all saved highlights
- Formatting toolbar (bold, italic, tags)

---

## 🐛 Troubleshooting

### "No code signing identities found"
1. Go to Xcode → Settings → Accounts
2. Add your Apple ID
3. Select your team in the project settings

### "Failed to create build operation"
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
xcodegen generate
```

### Simulator not showing up
1. **Window → Devices and Simulators**
2. Check if simulators are listed
3. Download iOS/iPadOS runtime if needed (Xcode → Settings → Platforms)

### App crashes on launch
1. Check Console output in Xcode (bottom panel)
2. Look for error messages in red
3. Common issues:
   - Core Data model changes (delete app from simulator and rebuild)
   - File path issues (check sample PDF is in bundle)

---

## 🎯 Testing Checklist

### Basic Flow
- [ ] Launch app
- [ ] Create new project with research question
- [ ] Add source from URL
- [ ] PDF opens in reader
- [ ] Enable highlight mode
- [ ] Select text and highlight
- [ ] See toast confirmation
- [ ] Navigate back to project
- [ ] See highlights in "Notes & Excerpts"

### Edge Cases
- [ ] Create project without research question
- [ ] Import invalid URL
- [ ] Import protected PDF
- [ ] Delete project with sources
- [ ] Navigate between multiple projects

---

## 🔄 Hot Reload / Live Preview

Unfortunately, SwiftUI Previews don't work well with complex apps that use Core Data. Instead:

1. **Use Simulator** - Build time is ~5-10 seconds
2. **Keep app running** - Make small changes and rebuild
3. **Sample data** - App creates sample data on first launch for quick testing

---

## 📊 Performance Notes

### Simulator Limitations
- **No Apple Pencil**: Pencil features require real iPad
- **Slower PDF rendering**: Real device is faster
- **No haptics**: Haptic feedback won't work
- **Different memory**: May behave differently under memory pressure

### Testing on Real iPad (Optional)
1. Connect iPad via USB
2. Select your iPad from device selector
3. Trust computer on iPad
4. May need to enable Developer Mode (Settings → Privacy & Security)

---

## 🔍 Useful Xcode Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd + R` | Build and run |
| `Cmd + B` | Build only |
| `Cmd + .` | Stop |
| `Cmd + K` | Clear console |
| `Cmd + Shift + K` | Clean build folder |
| `Cmd + Shift + O` | Quick open (search files) |
| `Cmd + 0` | Show/hide navigator |
| `Cmd + Shift + Y` | Show/hide debug area |
| `Cmd + /` | Comment/uncomment line |
| `Cmd + [` / `]` | Indent left/right |

---

## 📝 Git Workflow

The `.gitignore` is already configured to exclude:
- `LitRev.xcodeproj/` (generated by XcodeGen)
- Build artifacts
- Xcode user data
- macOS system files

Only commit:
- Source code (`LitRev/`)
- `project.yml` (XcodeGen config)
- Documentation files
- Assets

---

## 🆘 Need Help?

1. Check Console output in Xcode
2. Look for `print()` statements with emoji prefixes:
   - 📄 Metadata extraction
   - 📚 Source creation
   - ✅ Success operations
   - ❌ Errors
3. Check file paths are correct
4. Verify Core Data relationships

---

## 🎉 Next Steps

Once basic testing works:
1. Test all features systematically
2. Try edge cases (empty states, errors)
3. Test on real iPad with Apple Pencil
4. Add more test documents
5. Improve UI/UX based on usage

Happy coding! 🚀

