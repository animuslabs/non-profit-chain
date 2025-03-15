#!/bin/bash

# Set the API endpoint
API_URL="https://api.np.animus.is"

# Function to retrieve and display blockchain information
function get_blockchain_info {
    echo "Retrieving blockchain information from $API_URL..."

    # Get current blockchain information
    echo -e "\n--- Blockchain Info ---"
    cleos --url $API_URL get info

    # Get information on the latest block
    LATEST_BLOCK=$(cleos --url $API_URL get info | jq '.head_block_num')
    echo -e "\n--- Latest Block ($LATEST_BLOCK) ---"
    cleos --url $API_URL get block $LATEST_BLOCK

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
