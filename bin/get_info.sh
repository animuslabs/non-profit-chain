#!/bin/bash

# Source configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "${SCRIPT_DIR}/config.sh"

# Use ENDPOINT from config.sh
API_URL="$ENDPOINT"

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

# Function to retrieve and display public keys for special accounts
function get_account_keys {
    echo -e "\n--- Special Account Keys ---"
    echo "Retrieving public keys for special accounts from $API_URL..."

    for ACCOUNT in "${SPECIAL_ACCOUNTS[@]}"
    do
        echo -e "\n--- Account: $ACCOUNT ---"
        ACCOUNT_INFO=$(cleos --url $API_URL get account $ACCOUNT --json)
        if [ $? -ne 0 ]; then
            echo "Failed to retrieve information for account: $ACCOUNT"
            continue
        fi

        OWNER_KEYS=$(echo $ACCOUNT_INFO | jq -r '.permissions[] | select(.perm_name == "owner") | .required_auth.keys[].key')
        ACTIVE_KEYS=$(echo $ACCOUNT_INFO | jq -r '.permissions[] | select(.perm_name == "active") | .required_auth.keys[].key')

        echo "Owner Keys:"
        if [ -n "$OWNER_KEYS" ]; then
            echo "$OWNER_KEYS"
        else
            echo "No owner keys found."
        fi

        echo "Active Keys:"
        if [ -n "$ACTIVE_KEYS" ]; then
            echo "$ACTIVE_KEYS"
        else
            echo "No active keys found."
        fi
    done
}

# Execute the functions
get_blockchain_info
get_account_keys
