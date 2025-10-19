# Apple Pencil Support in LitRev

## Overview

LitRev now includes full Apple Pencil support for highlighting text in PDF documents using PencilKit.

## Features

### 🖍️ Highlight Mode with Apple Pencil

When you enable **Highlight Mode** in the PDF Reader:

1. **Apple Pencil Drawing**: Draw directly on the PDF with your Apple Pencil
   - The pencil acts as a yellow marker
   - Only the Apple Pencil is enabled (finger touch won't draw)
   - Smooth, natural drawing experience

2. **Automatic Text Extraction**: 
   - When you draw over text, the app automatically extracts the text underneath
   - The highlighted text is saved to "Notes & Excerpts"
   - Visual yellow highlight annotation is added to the PDF

3. **Text Selection (Alternative)**:
   - You can still use traditional text selection
   - Tap and hold to select text
   - Selected text is automatically highlighted and saved

## How to Use

### Step 1: Open a Document
- Import a PDF from Files or URL
- The document opens in the Source Reader

### Step 2: Enable Highlight Mode
- Tap the **"Enable Highlight"** button in the top toolbar
- The button will change to **"Highlighting Active"** with a yellow background
- The pencil icon will change to indicate active mode

### Step 3: Highlight with Apple Pencil
- Use your Apple Pencil to draw/mark over the text you want to highlight
- The app will:
  1. Show a yellow highlight on the PDF
  2. Extract the text under your drawing
  3. Save it as an excerpt in "Notes & Excerpts"
  4. Show a toast notification "✓ Saved to Notes & Quotes"

### Step 4: View Your Highlights
- Navigate back to the project
- Go to the "Notes & Excerpts" tab
- All highlighted text will be saved there with page numbers

## Technical Details

### PencilKit Integration
- Uses `PKCanvasView` for drawing
- Configured with `.pencilOnly` policy (only responds to Apple Pencil, not fingers)
- Yellow marker tool with 20pt width
- Transparent overlay on PDF for natural reading experience

### Coordinate Conversion
- Automatically converts canvas coordinates to PDF coordinates
- Works with zoomed and scrolled documents
- Accurate text extraction from highlighted regions

### Drawing Processing
- Strokes are processed immediately after completion
- Text is extracted from the bounded area
- Canvas is automatically cleared after processing
- Highlight annotations persist on the PDF

## Benefits

✅ **Natural Workflow**: Draw as you would with a physical highlighter
✅ **Precise**: Apple Pencil provides pixel-perfect precision
✅ **Fast**: Quick highlighting without menu navigation
✅ **Automatic**: Text extraction happens automatically
✅ **Non-intrusive**: Canvas is transparent when not in use

## Requirements

- iPad with Apple Pencil support
- iOS 16.0 or later
- PencilKit framework (included in iOS)

## Future Enhancements

Potential features for future versions:
- Multiple highlight colors
- Eraser tool for removing highlights
- Freehand notes/drawings saved separately
- PDF annotation export/import
- Handwriting recognition for notes

