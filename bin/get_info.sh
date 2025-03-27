#!/bin/bash

# Set the API endpoint
API_URL="http://127.0.0.1:8888"

# Function to retrieve and display blockchain information
function get_blockchain_info {
    echo "Retrieving blockchain information from $API_URL..."

    # Get current blockchain information
    echo -e "\n--- Blockchain Info ---"
    cleos --url $API_URL get info

    # Get information on the latest block - with fallback if jq not available
    if command -v jq &> /dev/null; then
        LATEST_BLOCK=$(cleos --url $API_URL get info | jq -r '.head_block_num')
    else
        LATEST_BLOCK=$(cleos --url $API_URL get info | grep -o '"head_block_num":[0-9]*' | sed 's/"head_block_num"://')
    fi

    if [ -n "$LATEST_BLOCK" ]; then
        echo -e "\n--- Latest Block ($LATEST_BLOCK) ---"
        cleos --url $API_URL get block $LATEST_BLOCK
    else
        echo -e "\n--- Could not determine latest block number ---"
    fi

    # Get account information
    ACCOUNT="eosio"
    echo -e "\n--- Account Info for '$ACCOUNT' ---"
    cleos --url $API_URL get account $ACCOUNT

    # Get producer schedule
    echo -e "\n--- Producer Schedule ---"
    cleos --url $API_URL get schedule
}

# Execute the function
get_blockchain_info
