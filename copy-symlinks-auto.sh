#!/bin/bash
# Script that goes through all of the symlinks in `./symlinks`, and copies their files over to
# `./files`. These are then git added, commited and pushed to Github.
# The script is triggered by a cronjob, and requires that the SSH-agent is forwarded to it.

# Find the SSH agent socket file and sets the SSH_AUTH_SOCK environment variable to enable SSH agent forwarding
echo "USER: $USER"
echo "SSH_AUTH_SOCK: $SSH_AUTH_SOCK"
echo "TEMP SSH SOCKETS:" find /tmp/ssh-* -type s -user "$USER" 2>/dev/null

# Store the original directory path
original_dir=$(pwd)

# Change directory to the script's location
pushd "$(dirname "$0")" > /dev/null

# Set the source directory containing the symlinks
# NOTE: this can be named to whatever one wishes the symlinks folder to be called
# as long as one also renames the `symlinks` folder.
source_directory="./symlinks"

# Set the target directory
# NOTE: this can similarly be named to whatever one wishes.
target_directory="./files"

# Create the target directory if it doesn't exist
mkdir -p "$target_directory"

# Iterate over the symlinks in the source directory and its subdirectories
find "$source_directory" -type l | while read -r link; do
  # Get the relative path of the symlink within the source directory
  relative_path="${link#$source_directory/}"
  
  # Get the absolute path of the original file
  file=$(readlink -f "$link")

  last_folder=$(basename "$file")

  # May be useful for debugging
  # echo "Last folder: $last_folder"
  # echo "File we are copying: $file"
  # echo "Path we are copying to: $target_directory/$(dirname "$relative_path")"

  # Create the corresponding directory structure in the target directory
  mkdir -p "$target_directory/$relative_path"

  # If it's a directory
  if [ -d "$file" ]; then 
    # Copy the original file to the target directory, preserving the structure
    cp -r "$file"/* "$target_directory/$relative_path"
  else 
    cp "$file" "$target_directory/$relative_path"
  fi
done

# Add the copied files to the Git repository
git add .

# Commit the changes
git commit -m "Updated files via copy-symlinks-auto.sh"

# Push
git push

# Return to the original directory
popd > /dev/null
