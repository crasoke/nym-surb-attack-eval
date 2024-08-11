#!/bin/sh
PASSWORD=wsadwsad

while ! [ -s "/nyx_volume/genesis.json" ] || ! [ -f "/contract_volume/mixnet_contract.wasm" ] || ! [ -f "/contract_volume/vesting_contract.wasm" ]; do
  sleep 1
done
# check if contract is already uploaded and instantiated
if [ ! -s "/nyx_volume/mixnet_contract_address" ]; then
  # a couple of sleeps in this file are needed so that it actually has time to be recorded in the blockchain
  sleep 10
  # recover alice wallet
  cp /nyx_volume/alice_mnemonic /root/alice_mnemonic
  (cat /root/alice_mnemonic; echo "$PASSWORD"; echo "$PASSWORD") | nyxd keys add alice --recover

  # upload mixnet contract
  (echo "$PASSWORD";sleep 3;yes) | nyxd tx wasm store /contract_volume/mixnet_contract.wasm  \
    --from=alice \
    --chain-id=nymtest-1 \
    --gas="auto" \
    --gas-adjustment=1.15 \
    --chain-id=nymtest-1 \
    --node=tcp://10.0.0.2:26657

  sleep 5
  
  ALICE_ADDRESS=$(echo "$PASSWORD" | nyxd keys show alice -a)
  # instantiate contract
  # this is more close to how the contract is instantiated in the main net
  # (echo "$PASSWORD";sleep 3;yes) | nyxd tx wasm instantiate 1 \
  #   "{\"rewarding_validator_address\": \"$ALICE_ADDRESS\",\"vesting_contract_address\": \"$ALICE_ADDRESS\",\"rewarding_denom\": \"unym\",\"epochs_in_interval\": 720,\"epoch_duration\": {\"secs\": 3600,\"nanos\": 0},\"initial_rewarding_params\": {\"initial_reward_pool\": \"100000\",\"initial_staking_supply\": \"90000\",\"staking_supply_scale_factor\": \"1.0\",\"sybil_resistance\": \"0.3\",\"active_set_work_factor\": \"10\",\"interval_pool_emission\": \"0.02\",\"rewarded_set_size\": 240,\"active_set_size\": 240}}" \
  #   --admin="$ALICE_ADDRESS" \
  #   --from alice \
  #   --label "testcontract" \
  #   --gas="auto" \
  #   --gas-adjustment=1.15 \
  #   --amount="100000unym" \
  #   --chain-id=nymtest-1 \
  #   --node=tcp://10.0.0.2:26657

  # this is a shorter versing with an active set size of 3, 3 min epoch duration and only 10 epochs in a interval
  (echo "$PASSWORD";sleep 3;yes) | nyxd tx wasm instantiate 1 \
    "{\"rewarding_validator_address\": \"$ALICE_ADDRESS\",\"vesting_contract_address\": \"$ALICE_ADDRESS\",\"rewarding_denom\": \"unym\",\"epochs_in_interval\": 10,\"epoch_duration\": {\"secs\": 180,\"nanos\": 0},\"initial_rewarding_params\": {\"initial_reward_pool\": \"10000000000\",\"initial_staking_supply\": \"9000000000\",\"staking_supply_scale_factor\": \"1.0\",\"sybil_resistance\": \"0.3\",\"active_set_work_factor\": \"10\",\"interval_pool_emission\": \"0.02\",\"rewarded_set_size\": 3,\"active_set_size\": 3}}" \
    --admin="$ALICE_ADDRESS" \
    --from alice \
    --label "mixcontract" \
    --gas="auto" \
    --gas-adjustment=1.15 \
    --amount="10000000000unym" \
    --chain-id=nymtest-1 \
    --node=tcp://10.0.0.2:26657

  sleep 10
  # makes sure that the contract is really uploaded and copy the contract address to the share
  nyxd query wasm list-contract-by-code 1 --node=tcp://10.0.0.2:26657 | grep \- | sed 's/- //' > /nyx_volume/mixnet_contract_address

  # now do the same with the vesting contract
  (echo "$PASSWORD";sleep 3;yes) | nyxd tx wasm store /contract_volume/vesting_contract.wasm  \
    --from=alice \
    --chain-id=nymtest-1 \
    --gas="auto" \
    --gas-adjustment=1.15 \
    --chain-id=nymtest-1 \
    --node=tcp://10.0.0.2:26657

  sleep 5

  (echo "$PASSWORD";sleep 3;yes) | nyxd tx wasm instantiate 2 \
    "{\"mix_denom\": \"unym\",\"mixnet_contract_address\": \"$(cat /nyx_volume/mixnet_contract_address)\"}" \
    --admin="$ALICE_ADDRESS" \
    --from alice \
    --label "vestingcontract" \
    --gas="auto" \
    --gas-adjustment=1.15 \
    --amount="10000000000unym" \
    --chain-id=nymtest-1 \
    --node=tcp://10.0.0.2:26657

  sleep 10
  nyxd query wasm list-contract-by-code 2 --node=tcp://10.0.0.2:26657 | grep \- | sed 's/- //' > /nyx_volume/vesting_contract_address

  # update the vesting contract address in the mixnet contract 
  (echo "$PASSWORD";sleep 3;yes) | nyxd tx wasm migrate $(cat /nyx_volume/mixnet_contract_address) 1 \
    "{\"vesting_contract_address\": \"$(cat /nyx_volume/vesting_contract_address)\"}" \
    --from alice \
    --chain-id=nymtest-1 \
    --node=tcp://10.0.0.2:26657

else
  echo "Contract already uploaded and initilized."
  echo "If you want to re-upload the contract, delete /nyx_volume/mixnet_contract_address and the whole blockchain"
fi