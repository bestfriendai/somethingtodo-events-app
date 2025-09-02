#!/bin/bash

# Function to fix withOpacity in a file
fix_file() {
    local file="$1"
    echo "Fixing $file..."
    
    # Create a temporary file
    temp_file="${file}.tmp"
    
    # Use sed to replace withOpacity with withValues
    sed 's/\.withOpacity(\([^)]*\))/.withValues(alpha: \1)/g' "$file" > "$temp_file"
    
    # Check if the file was changed
    if ! diff -q "$file" "$temp_file" > /dev/null 2>&1; then
        mv "$temp_file" "$file"
        echo "  ✓ Fixed $file"
    else
        rm "$temp_file"
        echo "  - No changes needed for $file"
    fi
}

# Find all Dart files with withOpacity and fix them
find lib -name "*.dart" -type f | while read -r file; do
    if grep -q "withOpacity" "$file"; then
        fix_file "$file"
    fi
done

echo "All files have been fixed!"
