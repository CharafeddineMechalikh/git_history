# Git History Export Scripts

This repository contains two scripts for exporting Git commit history from multiple repositories into individual CSV files and a summary CSV file.

## `export_git_history.sh`

This script exports the Git commit history for each repository into individual CSV files and a summary CSV file. It should be placed in the directory where your repositories are located.

### Usage

1. Download the `export_git_history.sh` script from this repository.

2. Place the script inside your local repository.

3. Open a terminal and navigate to the directory containing the script.

4. Run the script using the following command:

   ```bash
   ./export_git_history.sh
5. The script will collect the commit history for each repository and create individual CSV files for each repository's history as well as a summary CSV file.

   ## Exporting Commit History with `export_git_history_multiple.sh`

The `export_git_history_multiple.sh` script enhances the export process by providing a progress bar to visualize the export progress. It creates individual CSV files for each repository's commit history and generates a summary CSV file.

### Usage

1. **Download the Script**: Obtain the `export_git_history_multiple.sh` script from this repository.

2. **Placement**: Place the script in the directory where your repositories are located.

3. **Navigate to Directory**: Open a terminal and navigate to the directory containing the script.

4. **Run the Script**: Execute the script using the following command:

   ```bash
   ./export_git_history_multiple.sh
5. The script will collect the commit history for each repository and create individual CSV files for each repository's history as well as a summary CSV file. It will also display a progress bar to show the export progress.

## `removeZeros.sh`

This script processes a summary CSV file containing Git history data and replaces zero values in the columns with the last non-zero value. If the last non-zero value is missing, it is replaced with 0.

### Usage

1. **Clone the repository**:

   ```bash
   .\removeZeros.sh

### Output:

The processed CSV file will be saved as modified_summary_git_history.csv. Zero values in the columns will be replaced with the last non-zero value, and missing last non-zero values will be replaced with 0.

## Summary
These scripts provide an easy way to export Git commit history from multiple repositories into CSV files and process summary CSV files. Make sure to have the scripts in the same directory as your repositories before running them. The exported CSV files can be used for further analysis and visualization of your repositories' development history.

License
This project is licensed under the MIT License.
