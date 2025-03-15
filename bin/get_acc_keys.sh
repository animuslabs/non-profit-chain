#!/bin/bash

# Set the API endpoint
API_URL="https://api.np.animus.is"

# List of account names
ACCOUNTS=("seth" "john" "jun" "roberto" "gab" "luka" "bitcash" "animus" "boid" "btc" "eth" "user1" "user2" "user3" "user4" "prop.bitcash" "refe.bitcash")

# Function to retrieve and display public keys for each account
function get_account_keys {
    echo "Retrieving public keys for specified accounts from $API_URL..."

    for ACCOUNT in "${ACCOUNTS[@]}"
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

# Execute the function
get_account_keys
