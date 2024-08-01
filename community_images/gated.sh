#!/bin/bash

# Define the text content for README.md
readme_content="# Coverage Information

We offer comprehensive coverage solutions. Please contact us if you're interested in coverages. Visit our website at [rapidfort.com](https://www.rapidfort.com).

## Contact Information

For more details, please reach out through our [contact page](https://www.rapidfort.com/contact).

Thank you for your interest in our services.

---

**RapidFort Team**"

# Start directory
start_directory="."

# Function to create coverage directory and README.md
create_coverage_readme() {
    local dir="$1"
    local coverage_dir="$dir/coverage"

    # Create the coverage directory if it doesn't exist
    mkdir -p "$coverage_dir"

    # Create README.md with content
    echo "$readme_content" > "$coverage_dir/README.md"

    echo "Created coverage/README.md in $dir"
}

# Find all directories containing image.yml and process them
while IFS= read -r -d '' dir; do
    if [ -f "$dir/image.yml" ]; then
        echo "'image.yml' found in $dir. Creating coverage directory and README.md..."
        create_coverage_readme "$dir"
    fi
done < <(find "$start_directory" -type d -print0)

echo "Script completed."
