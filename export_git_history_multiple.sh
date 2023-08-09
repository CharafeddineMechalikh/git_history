#!/bin/bash

# Get the current directory where the script is located
current_directory="$( cd "$(dirname "$0")" ; pwd -P )"

# Directory containing repositories
repo_directory="$current_directory"

# Output directory for individual CSV files
output_directory="$current_directory"

# Output directory for the summary CSV file
summary_output="$current_directory"

# Remove previous CSV files
rm -f "$output_directory"/*_git_history.csv
rm -f "$summary_output"/summary_git_history.csv

# Count the number of repositories
total_repos=$(find "$repo_directory" -maxdepth 1 -type d | wc -l)
processed_repos=0

# Loop through each repository in the directory
for repo in "$repo_directory"/*; do
    if [ -d "$repo" ]; then
        repo_name=$(basename "$repo")
        
        # Navigate to the repository directory
        cd "$repo"
        
        # Get the Git log in a format suitable for parsing
        git_log=$(git log --format="%ad" --date=short | sort | uniq -c)
        
        # Prepare the CSV header
        echo "Date,Commit Count" > "$output_directory/${repo_name}_git_history.csv"
        
        # Initialize variables for cumulative commit count
        cumulative_count=0
        
        # Get total number of lines in the log
        total_lines=$(echo "$git_log" | wc -l)
        current_line=0
        
        # Loop through the Git log entries and extract date and cumulative commit count
        while read -r line; do
            current_line=$((current_line + 1))
            
            commit_count=$(echo "$line" | awk '{print $1}')
            date=$(echo "$line" | awk '{print $2}')
            cumulative_count=$((cumulative_count + commit_count))
            
            echo "$date,$cumulative_count" >> "$output_directory/${repo_name}_git_history.csv"
            
            # Calculate progress percentage
            progress_percentage=$((current_line * 100 / total_lines))
            echo -ne "Processing $repo_name: $progress_percentage% ($current_line/$total_lines)\r"
            
        done <<< "$git_log"
        
        echo -e "\nGit history exported to ${repo_name}_git_history.csv"
        processed_repos=$((processed_repos + 1))
        
    fi
done

# Combine individual CSV files into a summary CSV
summary_csv_header="Date"
repo_count=0
for repo_csv in "$output_directory"/*_git_history.csv; do
    repo_name=$(basename "$repo_csv" _git_history.csv)
    summary_csv_header+=",$repo_name"
    repo_count=$((repo_count + 1))
done
echo "$summary_csv_header" > "$summary_output/summary_git_history.csv"

# Calculate the total number of dates across all repositories
total_dates=0
for repo_csv in "$output_directory"/*_git_history.csv; do
    repo_dates=$(awk -F',' 'NR>1 {print $1}' "$repo_csv")
    total_dates=$((total_dates + $(echo "$repo_dates" | wc -w)))
done

# Initialize an empty array to hold all dates
all_dates=()

# Loop through the CSV files of each repository
for repo_csv in "$output_directory"/*_git_history.csv; do
    repo_dates=$(awk -F',' 'NR>1 {print $1}' "$repo_csv")
    
    # Append the dates from the current repository to the all_dates array
    all_dates=("${all_dates[@]}" $repo_dates)
    
    # Print the size of all_dates array after each addition
    echo "Size of all_dates array: ${#all_dates[@]}"
done

# Remove duplicates and sort the dates
unique_sorted_dates=$(echo "${all_dates[@]}" | tr ' ' '\n' | sort -u)

# Loop through the unique and sorted dates
for date in $unique_sorted_dates; do
    # Initialize the summary CSV line with the date
    summary_csv_line="$date"
    
    # Loop through the CSV files of each repository
    for repo_csv in "$output_directory"/*_git_history.csv; do
        # Extract commit count for the current date and repository
        commit_count=$(awk -F',' -v date="$date" '{if ($1 == date) print $2}' "$repo_csv")
        
        # If commit count is empty, use "0" as default
        [ -z "$commit_count" ] && commit_count=0
        
        # Append the commit count to the summary CSV line
        summary_csv_line+=",$commit_count"
    done
    
    # Append the summary CSV line to the summary output file
    echo "$summary_csv_line" >> "$summary_output/summary_git_history.csv"
    
    # Display progress
    processed_dates=$((processed_dates + 1))
    progress_percentage=$((processed_dates * 100 / (total_dates * repo_count)))
    echo -ne "Processing repositories: $progress_percentage% ($processed_dates/$((total_dates * repo_count)))\r"
done

echo "Summary CSV file created at $summary_output/summary_git_history.csv"
echo "Processed $processed_dates dates across $repo_count repositories"
 
