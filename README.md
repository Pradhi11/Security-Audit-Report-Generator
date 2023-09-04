# Security-Audit-Report-Generator


This script generates an HTML report based on the results of an npm audit. It provides a summary of vulnerabilities and allows you to search for vulnerabilities by package name or severity.

## Prerequisites

Before using this script, make sure you have the following installed:

- Node.js and npm (Node Package Manager): You can download and install Node.js from [nodejs.org](https://nodejs.org/).

## Usage

1. Clone or download this repository to your local machine.
2. Keep this file next to your package.json

3. Open a terminal and navigate to the directory containing the script.

4. Run the script using the following command:

   ```bash
   ./npmAudit.sh

   For MAC
   Give the permission to file
   chmod +x npmAudit.sh

   To Run file
   ./npmAudit.sh


* 		The script will execute npm audit --json to generate a JSON report of vulnerabilities in your project and then create an HTML report.
* 		Once the script completes, it will display the path to the generated HTML report.
* 		Open the HTML report in a web browser to view the vulnerabilities.

Searching for Vulnerabilities

The generated HTML report includes a search bar at the top. You can use this search bar to search for vulnerabilities based on package names or severity levels. Simply type your search query, and the report will filter the results accordingly.

Summary

The report includes a summary section that provides an overview of vulnerabilities by severity level. It also displays the total number of vulnerabilities in the audit report.

Customization

* You can customize the script to change the appearance of the HTML report by modifying the CSS styles in the script.
* To add additional customizations, such as including more details from the npm audit report, you can modify the generate_vulnerability_rows function in the script.
* 
Author
Pradeep
