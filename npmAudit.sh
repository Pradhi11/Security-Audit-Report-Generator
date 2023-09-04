#!/bin/bash

# Get the current working directory (root directory)
project_directory="$(pwd)"

report_file="$project_directory/audit_report.json"
output_file="$project_directory/audit_report.html"

# Run npm audit and save the JSON output to a file
npm audit --json > "$report_file"

# Define a function to generate table rows for vulnerabilities with background colors
generate_vulnerability_rows() {
    while IFS= read -r line; do
        package=$(echo "$line" | jq -r '.module_name')
        severity=$(echo "$line" | jq -r '.severity')
        module_version=$(echo "$line" | jq -r '.module_version')
        id=$(echo "$line" | jq -r '.id')
        title=$(echo "$line" | jq -r '.title')
        cvss_score=$(echo "$line" | jq -r '.cvss_score')
        cwe=$(echo "$line" | jq -r '.cwe')
        recommendation=$(echo "$line" | jq -r '.recommendation')
        url=$(echo "$line" | jq -r '.url')
        path=$(echo "$line" | jq -r '.findings[].paths[0]')

        # Determine the background color based on severity
        if [ "$severity" == "critical" ]; then
            background_color="#ff6666"
            text_color="white"
        elif [ "$severity" == "high" ]; then
            background_color="#607fab"
            text_color="white"
        elif [ "$severity" == "moderate" ]; then
            background_color="yellow"
            text_color="black"
        else
            background_color="#f2f2f2"
            text_color="black"
        fi

        # Generate the table row with background colors
        echo "<tr>"
        echo "<td style=\"background-color: $background_color; color: $text_color;\">$package</td>"
        echo "<td style=\"background-color: $background_color; color: $text_color;\">$severity</td>"
        echo "<td style=\"background-color: $background_color; color: $text_color;\">$module_version</td>"
        echo "<td style=\"background-color: $background_color; color: $text_color;\">$id</td>"
        echo "<td style=\"background-color: $background_color; color: $text_color;\">$title</td>"
        echo "<td style=\"background-color: $background_color; color: $text_color;\">$cvss_score</td>"
        echo "<td style=\"background-color: $background_color; color: $text_color;\">$cwe</td>"
        echo "<td style=\"background-color: $background_color; color: $text_color;\">$recommendation</td>"
        echo "<td style=\"background-color: $background_color; color: $text_color;\"><a href=\"$url\">$url</a></td>"
        echo "<td style=\"background-color: $background_color; color: $text_color;\">$path</td>"
        echo "</tr>"
    done < <(jq -c '.advisories | to_entries[] | .value' "$report_file")
}

# Count the number of vulnerabilities for each severity level
count_critical=$(jq -c '.advisories | map(select(.severity == "critical")) | length' "$report_file")
count_high=$(jq -c '.advisories | map(select(.severity == "high")) | length' "$report_file")
count_moderate=$(jq -c '.advisories | map(select(.severity == "moderate")) | length' "$report_file")
count_low=$(jq -c '.advisories | map(select(.severity == "low")) | length' "$report_file")
total_vulnerabilities=$(jq -c '.advisories | length' "$report_file")

# Check if the JSON report contains any vulnerabilities
if jq -e '.advisories' "$report_file" > /dev/null; then
    # Generate an HTML report
    cat <<EOF > "$output_file"
<!DOCTYPE html>
<html>
<head>
    <title>Security Audit Report</title>
    <style>
        table {
            border-collapse: collapse;
            width: 100%;
        }
        th, td {
            border: 1px solid black;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        /* Responsive styles */
        @media (max-width: 600px) {
            table {
                font-size: 12px;
            }
        }
        /* Watermark styles */
        body::after {
            content: "Pradeep";
            position: fixed;
            opacity: 0.1;
            font-size: 4em;
            bottom: 20px;
            right: 20px;
            z-index: -1;
        }
        /* Search bar styles */
        .search-container {
            text-align: center;
            margin-top: 20px;
            margin-bottom: 20px;
        }
        .search-input {
            padding: 8px;
            width: 60%;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }
    </style>
    <script>
        function searchTable() {
            var input, filter, table, tr, td, i, txtValue;
            input = document.getElementById("searchInput");
            filter = input.value.toUpperCase();
            table = document.getElementById("vulnerabilityTable");
            tr = table.getElementsByTagName("tr");
            for (i = 0; i < tr.length; i++) {
                td = tr[i].getElementsByTagName("td")[0];
                tdSeverity = tr[i].getElementsByTagName("td")[1];
                if (td) {
                    txtValue = td.textContent || td.innerText;
                    txtSeverity = tdSeverity.textContent || tdSeverity.innerText;
                    if (txtValue.toUpperCase().indexOf(filter) > -1 || txtSeverity.toUpperCase().indexOf(filter) > -1) {
                        tr[i].style.display = "";
                    } else {
                        tr[i].style.display = "none";
                    }
                }
            }
        }
    </script>
</head>
<body>
    <h1>Security Audit Report</h1>
    <div class="search-container">
        <input type="text" id="searchInput" class="search-input" onkeyup="searchTable()" placeholder="Search by Package or Severity">
    </div>
    <table id="vulnerabilityTable">
        <thead>
            <tr>
                <th>Package</th>
                <th>Severity</th>
                <th>Version</th>
                <th>Advisory ID</th>
                <th>Advisory Title</th>
                <th>CVSS Score</th>
                <th>CWE</th>
                <th>Recommendation</th>
                <th>URL</th>
                <th>Path</th>
            </tr>
        </thead>
        <tbody>
            $(generate_vulnerability_rows)
        </tbody>
    </table>
    <h2>Summary</h2>
    <table>
        <tr>
            <th>Severity</th>
            <th>Count</th>
        </tr>
        <tr>
            <td>Critical</td>
            <td>$count_critical</td>
        </tr>
        <tr>
            <td>High</td>
            <td>$count_high</td>
        </tr>
        <tr>
            <td>Moderate</td>
            <td>$count_moderate</td>
        </tr>
        <tr>
            <td>Low</td>
            <td>$count_low</td>
        </tr>
        <tr>
            <td>Total Vulnerabilities</td>
            <td>$total_vulnerabilities</td>
        </tr>
    </table>
</body>
</html>
EOF

    echo "HTML report generated: $output_file"
else
    echo "No vulnerabilities found in the npm audit report."
fi
