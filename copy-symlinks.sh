#!/bin/bash
# Script that goes through all of the symlinks in `./symlinks`, and copies their files over to
# `./files`. This script does not trigger via a cronjob, and needs one to trigger it manually.
# It also does not commit any of the changes to Git.

# Store the original directory path
original_dir=$(pwd)

# Change directory to this script's location
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
  mkdir -p "$target_directory/$(dirname "$relative_path")"

  # If it's a directory
  if [ -d "$file" ]; then 
    # Copy the original file to the target directory, preserving the structure
    cp -r "$file"/* "$target_directory/$relative_path"
  else 
    cp "$file" "$target_directory/$relative_path"
  fi
done

# Return to the original directory
popd > /dev/null
