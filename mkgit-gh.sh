#!/bin/sh

# Check for required tools
if ! command -v git &> /dev/null; then
  echo "Error: git is not installed"
  exit 1
fi

if ! command -v gh &> /dev/null; then
  echo "Error: github-cli is not installed"
  exit 1
fi

# Get user input:
read -p "Enter desired repository name (or leave empty for auto-naming): " repo_name
read -p "Enter repository description (optional): " description
read -p "Choose visibility (public, private, internal): " visibility
read -p "Include a LICENSE file (y/n): " include_license

# Validate user input
if [[ -z "$repo_name" ]]; then
  # Auto-generate name based on date and time
  timestamp=$(date +%Y-%m-%d_%H-%M-%S)
  repo_name="new-repo_$timestamp"
fi

if [[ ! "$visibility" =~ ^(public|private|internal)$ ]]; then
  echo "Invalid visibility choice. Please enter public, private, or internal."
  exit 1
fi

# Define license file path based on user choice
license_file=""
if [[ "$include_license" =~ ^(y|Y)$ ]]; then
  license_file="LICENSE"
fi

# Create repository directory
mkdir -p "$repo_name" || exit 1
cd "$repo_name"

# Initialize Git repository
git init || exit 1

# Create basic README file with description
echo "# $repo_name" > README.md
echo "" >> README.md
if [[ -n "$description" ]]; then
  echo "$description" >> README.md
fi

# Add and commit README file
git add README.md || exit 1
git commit -m "Initial commit" || exit 1

# Use GitHub CLI to create remote repository and push initial commit
gh repo create \
  --"$visibility" \
  --name "$repo_name" \
  --description "$description" \
  || exit 1

git remote add origin "https://github.com/$USER/$repo_name.git" || exit 1
git push origin main || exit 1

# Additional setup based on options:
if [[ -n "$license_file" ]]; then
  # Download a basic LICENSE file
  curl -o "$license_file" https://raw.githubusercontent.com/github/choosealicense/choosealicense.github.io/gh-pages/licenses/MIT.txt || exit 1
  git add "$license_file" && git commit -m "Added LICENSE file"
fi

echo "Successfully created and pushed repository: https://github.com/$USER/$repo_name"
