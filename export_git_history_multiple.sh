#!/bin/bash

# Get the current directory where the script is located
current_directory="$( cd "$(dirname "$0")" ; pwd -P )"

# Directory containing repositories
repo_directory="$current_directory"

# Output directory for individual CSV files
output_directory="$current_directory"

# Output directory for the summary CSV file
summary_output="$current_directory"

# Count the number of repositories
repo_count=$(find "$repo_directory" -maxdepth 1 -type d | wc -l)

# Initialize progress variables
current_repo=0

# Declare an associative array to store commit counts for each repository
declare -A commit_counts

# Loop through each repository in the directory
for repo in "$repo_directory"/*; do
    if [ -d "$repo" ]; then
        repo_name=$(basename "$repo")
        
        # Navigate to the repository directory
        cd "$repo"
        
        # Get the Git log in a format suitable for parsing
        git_log=$(git log --format="%ad" --date=short | sort | uniq -c)
        
        # Initialize variables for cumulative commit count
        cumulative_count=0
        
        # Loop through the Git log entries and extract date and cumulative commit count
        while read -r line; do
            commit_count=$(echo "$line" | awk '{print $1}')
            date=$(echo "$line" | awk '{print $2}')
            cumulative_count=$((cumulative_count + commit_count))
            commit_counts["$repo_name,$date"]=$cumulative_count
        done <<< "$git_log"
        
        echo "Git history collected for $repo_name"
        
        # Update progress
        current_repo=$((current_repo + 1))
        progress=$((current_repo * 100 / repo_count))
        echo -ne "Progress: $progress% \r"
    fi
done

# Prepare the CSV header for the summary CSV
header="Date"
for repo_name in "${!commit_counts[@]}"; do
    header="$header,$repo_name"
done

echo "$header" > "$summary_output/summary_git_history.csv"

# Loop through unique dates and assemble the summary CSV row
unique_dates=($(cut -d',' -f2 <<< "${!commit_counts[@]}" | sort -u))
for date in "${unique_dates[@]}"; do
    row="$date"
    for repo_name in "${!commit_counts[@]}"; do
        commit_count=${commit_counts[$repo_name]}
        row="$row,$commit_count"
    done
    echo "$row" >> "$summary_output/summary_git_history.csv"
done

echo "Summary CSV file created at $summary_output/summary_git_history.csv"
