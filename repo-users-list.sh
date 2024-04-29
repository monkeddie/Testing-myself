#!/bin/bash

# Function to extract organization and repository names from URL
extract_repo_info() {
    if [[ "$1" =~ github.com/([^/]+)/([^/]+) ]]; then
        org_name="${BASH_REMATCH[1]}"
        repo_name="${BASH_REMATCH[2]}"
    else
        echo "Error: Invalid repository URL"
        exit 1
    fi
}

# Prompt the user to choose input method
read -p "Enter '1' to input organization and repository names, or '2' to input repository URL: " input_method

# If input method is 1, prompt the user to input organization and repository names
if [ "$input_method" = "1" ]; then
    read -p "Enter the name of the organization: " org_name
    read -p "Enter the name of the repository: " repo_name
    repo_url=""
# If input method is 2, prompt the user to input repository URL
elif [ "$input_method" = "2" ]; then
    read -p "Enter the URL of the repository: " repo_url
    org_name=""
    repo_name=""
else
    echo "Error: Invalid input method"
    exit 1
fi

# If repository URL is provided, extract organization and repository names from it
if [ -n "$repo_url" ]; then
    extract_repo_info "$repo_url"
fi

# Prompt the user to input the personal access token
read -s -p "Enter your GitHub personal access token: " token
echo

# Make a GET request to the GitHub API to retrieve the list of contributors
response=$(curl -s -H "Authorization: token $token" "https://api.github.com/repos/$org_name/$repo_name/contributors")

# Check if the request was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to retrieve contributors from the GitHub API"
    exit 1
fi

# Parse the JSON response to extract the contributors' usernames
contributors=$(echo "$response" | grep -oP '(?<="login": ")[^"]+' | sort -u)

# Print the list of contributors
echo "Users with access to the repository:"
echo "$contributors"

# Exit successfully
exit 0

