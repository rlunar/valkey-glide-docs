#!/bin/bash

# Script to add appropriate badges to all MDX files in the project
# Logic:
# 1. Placeholder badge for files containing "This is a placeholder" and under 600 bytes
# 2. Skip files that already have badge text defined
# 3. Add Draft badge to remaining files

set -e

echo "Adding appropriate badges to all MDX files..."

# Count files processed
processed_count=0
skipped_count=0
placeholder_count=0
draft_count=0

# Create temporary files for counting
temp_dir=$(mktemp -d)
placeholder_count_file="$temp_dir/placeholder_count"
draft_count_file="$temp_dir/draft_count"
skipped_count_file="$temp_dir/skipped_count"

echo "0" > "$placeholder_count_file"
echo "0" > "$draft_count_file"
echo "0" > "$skipped_count_file"

# Function to process a single file
process_file() {
    local file="$1"
    echo "Processing: $file"
    
    # Get file size in bytes
    file_size=$(wc -c < "$file")
    
    # Check if file contains "This is a placeholder" and is under 600 bytes
    if grep -q "This is a placeholder" "$file" && [ "$file_size" -lt 600 ]; then
        # Check if already has a Placeholder badge
        if grep -q "text: Placeholder" "$file"; then
            echo "  ⚠️  Skipped - already has Placeholder badge: $file"
            echo $(($(cat "$skipped_count_file") + 1)) > "$skipped_count_file"
            continue
        fi
        
        # Add or update to Placeholder badge
        if grep -q "sidebar:" "$file" && grep -q "badge:" "$file"; then
            # Update existing badge to Placeholder using a temp file for portability
            temp_sed_file=$(mktemp)
            sed 's/text: Draft/text: Placeholder/g; s/variant: caution/variant: note/g' "$file" > "$temp_sed_file"
            mv "$temp_sed_file" "$file"
        else
            # Add new sidebar with Placeholder badge
            temp_file=$(mktemp)
            awk '
            BEGIN {
                in_frontmatter = 0
                frontmatter_ended = 0
            }
            
            # Detect start of frontmatter
            /^---$/ && NR == 1 {
                in_frontmatter = 1
                print $0
                next
            }
            
            # Detect end of frontmatter
            /^---$/ && in_frontmatter && !frontmatter_ended {
                frontmatter_ended = 1
                in_frontmatter = 0
                
                # Add sidebar with Placeholder badge before closing frontmatter
                print "sidebar:"
                print "  badge:"
                print "    text: Placeholder"
                print "    variant: note"
                print $0
                next
            }
            
            # Print all other lines as-is
            {
                print $0
            }
            ' "$file" > "$temp_file"
            
            mv "$temp_file" "$file"
        fi
        
        echo "  🏷️  Added Placeholder badge to: $file"
        echo $(($(cat "$placeholder_count_file") + 1)) > "$placeholder_count_file"
        continue
    fi
    
    # Check if the file already has any badge text defined
    if grep -q "sidebar:" "$file" && grep -q "badge:" "$file" && grep -q "text:" "$file"; then
        echo "  ⚠️  Skipped - already has badge text defined: $file"
        echo $(($(cat "$skipped_count_file") + 1)) > "$skipped_count_file"
        continue
    fi
    
    # Add Draft badge if no badge exists
    if ! (grep -q "sidebar:" "$file" && grep -q "badge:" "$file"); then
        # Create a temporary file
        temp_file=$(mktemp)
        
        # Process the file to add Draft badge
        awk '
        BEGIN {
            in_frontmatter = 0
            frontmatter_ended = 0
        }
        
        # Detect start of frontmatter
        /^---$/ && NR == 1 {
            in_frontmatter = 1
            print $0
            next
        }
        
        # Detect end of frontmatter
        /^---$/ && in_frontmatter && !frontmatter_ended {
            frontmatter_ended = 1
            in_frontmatter = 0
            
            # Add sidebar with Draft badge before closing frontmatter
            print "sidebar:"
            print "  badge:"
            print "    text: Draft"
            print "    variant: caution"
            print $0
            next
        }
        
        # Print all other lines as-is
        {
            print $0
        }
        ' "$file" > "$temp_file"
        
        # Replace the original file with the processed version
        mv "$temp_file" "$file"
        
        echo "  ✅ Added Draft badge to: $file"
        echo $(($(cat "$draft_count_file") + 1)) > "$draft_count_file"
    else
        echo "  ⚠️  Skipped - already has sidebar structure: $file"
        echo $(($(cat "$skipped_count_file") + 1)) > "$skipped_count_file"
    fi
}

# Use a temporary file to store the list of files
temp_files_list="$temp_dir/files_list"
find src/content/docs -name "*.mdx" -type f > "$temp_files_list"

# Process each file
while IFS= read -r file; do
    process_file "$file"
done < "$temp_files_list"

# Read final counts
placeholder_count=$(cat "$placeholder_count_file")
draft_count=$(cat "$draft_count_file")
skipped_count=$(cat "$skipped_count_file")

# Clean up temporary files
rm -rf "$temp_dir"

echo ""
echo "🎉 Finished processing all MDX files!"
echo "📊 Results:"
echo "  🏷️  Placeholder badges added: $placeholder_count files"
echo "  ✅ Draft badges added: $draft_count files"
echo "  ⏭️  Skipped: $skipped_count files (already had badges)"