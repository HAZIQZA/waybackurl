#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -d <domain> -o <wayback_output_file name>"
    exit 1
}

# Parse command-line arguments
while getopts "d:o:" opt; do
    case "$opt" in
        d) domain=$OPTARG ;;
        o) wayback_output_file=$OPTARG ;;
        *) usage ;;
    esac
done

# Validate inputs
if [[ -z "$domain" || -z "$wayback_output_file" ]]; then
    echo "Error: Domain and output file are required."
    usage
fi

# Check if waybackurls is installed
if ! command -v waybackurls &> /dev/null; then
    echo "Installing waybackurls...."
    go install github.com/tomnomnom/waybackurls@latest
    echo "Please enter the root password:"
    read -s root_passwd
    echo -e "\n\nPlease wait..."
    echo $root_passwd | sudo -S cp ~/go/bin/waybackurls /usr/local/bin
fi

# Fetch URLs using waybackurls
waybackurls "$domain" > "$wayback_output_file" &

pid=$!

sleep 10s ;kill $pid

if [[ $? -eq 0 ]]; then
    echo "URLs successfully fetched and saved to $wayback_output_file"
else
    echo "Error: Failed to fetch URLs."
    exit 1
fi

#------------------------------------------------------------------------------------

# Define the output directory where the URLs are saved

OUTPUT_DIR="./"
ALL_URLS_FILE="./$wayback_output_file"  # The file containing all extracted URLs


    if [ ! -f $OUTPUT_DIR/js_urls.txt ]
    then
    {
        touch $OUTPUT_DIR/js_urls.txt $OUTPUT_DIR/file_types.txt $OUTPUT_DIR/parameters.txt $OUTPUT_DIR/base_urls.txt $OUTPUT_DIR/subdomains.txt $OUTPUT_DIR/api_endpoints.txt \
        $OUTPUT_DIR/sensitive_files.txt $OUTPUT_DIR/js_keywords.txt $OUTPUT_DIR/http_methods.txt $OUTPUT_DIR/parameter_names.txt $OUTPUT_DIR/domains.txt $OUTPUT_DIR/extensions.txt $OUTPUT_DIR/keywords.txt $OUTPUT_DIR/authentication.txt $OUTPUT_DIR/wordpress.txt $OUTPUT_DIR/cleaned_urls.txt
    
    }
    fi
# Function to count and display URLs in each category
count_urls() {

    echo "JavaScript URLs: $(wc -l < $OUTPUT_DIR/js_urls.txt) URLs"
    echo "File types: $(wc -l < $OUTPUT_DIR/file_types.txt) URLs"
    echo "Parameters: $(wc -l < $OUTPUT_DIR/parameters.txt) URLs"
    echo "Base URLs: $(wc -l < $OUTPUT_DIR/base_urls.txt) URLs"
    echo "Subdomains: $(wc -l < $OUTPUT_DIR/subdomains.txt) URLs"
    echo "API endpoints: $(wc -l < $OUTPUT_DIR/api_endpoints.txt) URLs"
    echo "Sensitive files: $(wc -l < $OUTPUT_DIR/sensitive_files.txt) URLs"
    echo "JS with keywords: $(wc -l < $OUTPUT_DIR/js_keywords.txt) URLs"
    echo "HTTP methods: $(wc -l < $OUTPUT_DIR/http_methods.txt) URLs"
    echo "Parameter names: $(wc -l < $OUTPUT_DIR/parameter_names.txt) names"
    echo "Domains: $(wc -l < $OUTPUT_DIR/domains.txt) domains"
    echo "Extensions: $(wc -l < $OUTPUT_DIR/extensions.txt) URLs"
    echo "Keywords: $(wc -l < $OUTPUT_DIR/keywords.txt) URLs"
    echo "Authentication: $(wc -l < $OUTPUT_DIR/authentication.txt) URLs"
    echo "WordPress: $(wc -l < $OUTPUT_DIR/wordpress.txt) URLs"
    echo "Cleaned URLs: $(wc -l < $OUTPUT_DIR/cleaned_urls.txt) URLs"
}

# Function to extract and categorize URLs based on different filters

filter_urls() {
    # JavaScript URLs
    grep -E "\.js$" $ALL_URLS_FILE > $OUTPUT_DIR/js_urls.txt

    # File types (e.g., .php, .asp, etc.)
    grep -E "\.(php|asp|aspx|jsp)$" $ALL_URLS_FILE > $OUTPUT_DIR/file_types.txt

    # Parameters in URLs
    grep "\?" $ALL_URLS_FILE > $OUTPUT_DIR/parameters.txt

    # Base URLs (remove query strings)
    grep -oP "https?://[^?]+" $ALL_URLS_FILE > $OUTPUT_DIR/base_urls.txt

    # Subdomains (customize for your target)
    grep "subdomain.target.com" $ALL_URLS_FILE > $OUTPUT_DIR/subdomains.txt

    # API endpoints
    grep -E "/api|/v1|/v2|/graphql" $ALL_URLS_FILE > $OUTPUT_DIR/api_endpoints.txt

    # Sensitive files (e.g., .env, .log, etc.)
    grep -E "\.(env|log|json|conf|bak|old|txt)$" $ALL_URLS_FILE > $OUTPUT_DIR/sensitive_files.txt

    # JS URLs with specific keywords (e.g., config, key, token)
    grep -E "\.js$" $ALL_URLS_FILE | grep -iE "config|key|token" > $OUTPUT_DIR/js_keywords.txt

    # HTTP methods (e.g., PUT, POST, DELETE)
    grep -E "PUT|POST|DELETE" $ALL_URLS_FILE > $OUTPUT_DIR/http_methods.txt

    # Parameter names (from query strings)
    grep "\?" $ALL_URLS_FILE | awk -F'?' '{print $2}' | awk -F'&' '{for(i=1;i<=NF;i++) print $i}' | awk -F'=' '{print $1}' | sort | uniq > $OUTPUT_DIR/parameter_names.txt

    # Domains (unique domains from the URLs)
    awk -F/ '{print $3}' $ALL_URLS_FILE | sort | uniq > $OUTPUT_DIR/domains.txt

    # Extensions (file extensions)
    grep -E "\.ext$" $ALL_URLS_FILE > $OUTPUT_DIR/extensions.txt

    # Keywords (e.g., sensitive terms like error, admin, etc.)
    grep -E "\.php$|\.asp$|\.js$|\.txt$" $ALL_URLS_FILE | grep -i "error|login|admin" > $OUTPUT_DIR/keywords.txt

    # Authentication-related URLs (e.g., login, token)
    grep "\?" $ALL_URLS_FILE | grep -i "auth|token|password" > $OUTPUT_DIR/authentication.txt

    # WordPress-related URLs
    grep -E "wp-content|wp-includes" $ALL_URLS_FILE > $OUTPUT_DIR/wordpress.txt

    # Cleaned URLs (filter out duplicates)
    sort -u $ALL_URLS_FILE > $OUTPUT_DIR/cleaned_urls.txt
}

# Function to fuzz URLs with ffuf tool (example)
fuzz_urls() {
    ffuf -w $OUTPUT_DIR/cleaned_urls.txt -u FUZZ -t 50 -c
}

# Call the functions
count_urls
filter_urls

# Optional: Run the fuzzing tool (uncomment if needed)
# fuzz_urls


#usage example 
#sudo ./waybackurl_arya\'s.sh -d bugcrowd.com -o full_urls


#created by -HAZIQZA-