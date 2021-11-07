#!/usr/bin/env bash

# Clear screen
clear

# Set correct working directory
# Credit: https://stackoverflow.com/a/246128/4776676
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

if [ ! -d "UnsplashViewer" ]; then
	echo "Unrecognized directory"
	# Display farewell message
	echo "Press any key to close"
	read -n 1 -s
fi

cd UnsplashViewer

# Read secrets
printf "Paste your API key here: "
read APIKEY
printf "\n"

# Create Credentials folder if necessary
if [ ! -d "Credentials" ]; then
	mkdir "Credentials"
fi

# Write entered secrets to Secrets.swift with correct 'struct Secret' structure
cd "Credentials" && 
cat > Credentials.swift  << ENDOFFILE
//
//  Credentials.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 05.11.2021.
//

import Foundation

enum Credentials {
    static let apiKey = "$APIKEY"
}

ENDOFFILE

if [ -f "Credentials.swift" ]; then
	echo "Success. "
else
	echo "Something went wrong :("
fi

# Display farewell message
echo "Press any key to close"
read -n 1 -s
