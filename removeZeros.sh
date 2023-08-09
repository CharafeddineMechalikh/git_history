#!/bin/bash

# Input file (summary_git_history.csv)
input_file="summary_git_history.csv"

# Output file (modified_summary_git_history.csv)
output_file="modified_summary_git_history.csv"

# Read the header line and write it directly to the output file with commas added
IFS=',' read -r -a header < "$input_file"
output_header=$(IFS=','; echo "${header[*]}")
echo "$output_header" > "$output_file"

# Initialize an associative array to hold the last non-zero values for each column
declare -A last_values

# Read the remaining lines (excluding the header) and process them
tail -n +2 "$input_file" | while IFS=',' read -r -a values; do
    # Loop through each value and update last_values and modified_values arrays
    for ((i = 1; i < ${#values[@]}; i++)); do
        column="${header[$i]}"
        value="${values[i]}"
        
        if [ "$value" -ne 0 ]; then
            last_values["$column"]=$value
        elif [ -n "${last_values["$column"]}" ]; then
            values[i]=${last_values["$column"]}
        else
            values[i]=0
        fi
    done
    
    # Join the modified values back into a line
    modified_line=$(IFS=','; echo "${values[*]}")
    
    # Write the modified line to the output file
    echo "$modified_line" >> "$output_file"
done

echo "Zero values replaced with last non-zero values in $input_file and saved to $output_file"
