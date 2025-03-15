#!/usr/bin/env bash

ENDPOINT_ONE=$1
WALLET_DIR=$2

cleos --url $ENDPOINT_ONE transfer eosio impact "10000 IMPACT" "init funding"
cleos --url $ENDPOINT_ONE system buyram eosio impact "1000 IMPACT"

# create 21 producers error out if vars not set
for producer_name in bpa bpb bpc
do
    [ ! -s "$WALLET_DIR/${producer_name}.keys" ] && cleos create key --to-console > "$WALLET_DIR/${producer_name}.keys"
    # head because we want the first match; they may be multiple keys
    PRIVATE_KEY=$(grep Private "$WALLET_DIR/${producer_name}.keys" | head -1 | cut -d: -f2 | sed 's/ //g')
    PUBLIC_KEY=$(grep Public "$WALLET_DIR/${producer_name}.keys" | head -1 | cut -d: -f2 | sed 's/ //g')
    cleos wallet import --name finality-test-network-wallet --private-key $PRIVATE_KEY

    # 400 staked per producer x21 = 8400 IMPACT staked total
    cleos --url $ENDPOINT_ONE system newaccount eosio ${producer_name:?} ${PUBLIC_KEY:?} --stake-net "500 IMPACT" --stake-cpu "500 IMPACT" --buy-ram "1000 IMPACT"
    # get some spending money
    cleos --url $ENDPOINT_ONE transfer eosio ${producer_name} "10000 IMPACT" "init funding"
    # self stake some net and cpu
    cleos --url $ENDPOINT_ONE system delegatebw ${producer_name} ${producer_name} "4000.0 IMPACT" "4000.0 IMPACT"
done

# create user keys
[ ! -s "$WALLET_DIR/user.keys" ] && cleos create key --to-console > "$WALLET_DIR/user.keys"
# head because we want the first match; they may be multiple keys
USER_PRIVATE_KEY=$(grep Private "$WALLET_DIR/user.keys" | head -1 | cut -d: -f2 | sed 's/ //g')
USER_PUBLIC_KEY=$(grep Public "$WALLET_DIR/user.keys" | head -1 | cut -d: -f2 | sed 's/ //g')
cleos wallet import --name finality-test-network-wallet --private-key $USER_PRIVATE_KEY

for user_name in seth john jun roberto gab luka bitcash animus boid btc eth user1 user2 user3 user4
do
  # create user account
  cleos --url $ENDPOINT_ONE system newaccount eosio ${user_name:?} ${USER_PUBLIC_KEY:?} --stake-net "50 IMPACT" --stake-cpu "50 IMPACT" --buy-ram "100 IMPACT"
  # get some spending money
  cleos --url $ENDPOINT_ONE transfer eosio ${user_name} "11540000 IMPACT" "init funding"
  # stake 1154K IMPACT x26 accounts = 300,004,000 IMPACT Total Staked
  cleos --url $ENDPOINT_ONE system delegatebw ${user_name} ${user_name} "5770000.000 IMPACT" "5770000.0000 IMPACT"
done

# Special accounts with large RAM and unstaked resources
for special_account in prop.bitcash refe.bitcash
do
  # Create account with substantial initial resources
  cleos --url $ENDPOINT_ONE system newaccount eosio ${special_account:?} ${USER_PUBLIC_KEY:?} --stake-net "5000 IMPACT" --stake-cpu "5000 IMPACT" --buy-ram "50000 IMPACT"
  
  # Transfer large amount of tokens but keep most unstaked
  cleos --url $ENDPOINT_ONE transfer eosio ${special_account} "10000000 IMPACT" "init funding"
  
  # Stake only a portion, leaving most liquid
  cleos --url $ENDPOINT_ONE system delegatebw ${special_account} ${special_account} "500000.000 IMPACT" "500000.0000 IMPACT"
  
  # Buy additional RAM
  cleos --url $ENDPOINT_ONE system buyram ${special_account} ${special_account} "100000 IMPACT"
done
