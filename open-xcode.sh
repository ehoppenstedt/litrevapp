#!/bin/bash

# LitRev - Open in Xcode Script
# This script generates the Xcode project and opens it

echo "🔧 Generating Xcode project..."
xcodegen generate

if [ $? -eq 0 ]; then
    echo "✅ Project generated successfully"
    echo "📱 Opening in Xcode..."
    open LitRev.xcodeproj
    echo "✨ Done! Select an iPad simulator and press Cmd+R to run"
else
    echo "❌ Error generating project"
    exit 1
fi

