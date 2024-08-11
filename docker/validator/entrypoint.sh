#!/bin/sh
PASSWORD=wsadwsad

cd /root

if [ "$1" = "genesis" ]; then
  if [ ! -f "/root/.nyxd/config/genesis.json" ]; then
    # create testnet
    nyxd init test1 --chain-id nymtest-1
    # rename stake to unyx
    sed -i. "s/\"stake\"/\"unyx\"/" /root/.nyxd/config/genesis.json

    # create accounts for validators, mixnodes and gateways and save the mnemonics
    (echo "$PASSWORD"; echo "$PASSWORD") | nyxd keys add alice 2>&1 | tail -n 1 > /nyx_volume/alice_mnemonic
    (echo "$PASSWORD"; echo "$PASSWORD") | nyxd keys add bob 2>&1 | tail -n 1 > /nyx_volume/bob_mnemonic
    (echo "$PASSWORD"; echo "$PASSWORD") | nyxd keys add mix1 2>&1 | tail -n 1 > /nyx_volume/mix1_mnemonic
    (echo "$PASSWORD"; echo "$PASSWORD") | nyxd keys add mix2 2>&1 | tail -n 1 > /nyx_volume/mix2_mnemonic
    (echo "$PASSWORD"; echo "$PASSWORD") | nyxd keys add mix3 2>&1 | tail -n 1 > /nyx_volume/mix3_mnemonic
    (echo "$PASSWORD"; echo "$PASSWORD") | nyxd keys add entry-gateway 2>&1 | tail -n 1 > /nyx_volume/entry-gateway_mnemonic
    (echo "$PASSWORD"; echo "$PASSWORD") | nyxd keys add exit-gateway 2>&1 | tail -n 1 > /nyx_volume/exit-gateway_mnemonic
    # add tokens to the accounts
    echo "$PASSWORD" | nyxd genesis add-genesis-account alice 1000000000000000unym,1000000000000000unyx
    echo "$PASSWORD" | nyxd genesis add-genesis-account bob 1000000000000000unym,1000000000000000unyx
    echo "$PASSWORD" | nyxd genesis add-genesis-account mix1 10000000000unym
    echo "$PASSWORD" | nyxd genesis add-genesis-account mix2 10000000000unym
    echo "$PASSWORD" | nyxd genesis add-genesis-account mix3 10000000000unym
    echo "$PASSWORD" | nyxd genesis add-genesis-account entry-gateway 10000000000unym
    echo "$PASSWORD" | nyxd genesis add-genesis-account exit-gateway 10000000000unym
    
    # make alice + bob a proper validator
    echo "$PASSWORD" | nyxd genesis gentx alice 1000000000unyx --chain-id nymtest-1
    nyxd genesis collect-gentxs
    nyxd genesis validate-genesis

    # copy genesis file for bob
    cp /root/.nyxd/config/genesis.json /nyx_volume/genesis.json
  else
    echo "Genesis Validator already initialized, starting with the existing configuration."
    echo "If you want to re-init the validator, destroy the existing container"
	fi
	nyxd start --rpc.laddr tcp://0.0.0.0:26657 --api.enable --api.address tcp://0.0.0.0:1317 --log_level=info --trace
elif [ "$1" = "secondary" ]; then
  if [ ! -f "/root/.nyxd/config/genesis.json" ]; then
    nyxd init test2 --chain-id nymtest-1

    # Wait until the genesis node writes the genesis.json to the shared volume
    while ! [ -s /nyx_volume/genesis.json ]; do
      sleep 1
    done

    sleep 5
    # copy necessary files
    cp /nyx_volume/genesis.json /root/.nyxd/config/genesis.json
    cp /nyx_volume/bob_mnemonic /root/.nyxd/

    # specify peer
    GENESIS_PEER=$(cat /root/.nyxd/config/genesis.json | grep '"memo"' | cut -d'"' -f 4)
    sed -i 's/persistent_peers = ""/persistent_peers = "'"${GENESIS_PEER}"'"/' /root/.nyxd/config/config.toml
    # sed -i 's/minimum-gas-prices = ""/minimum-gas-prices = "0.025stake"/' /root/.nyxd/config/app.toml

    (cat /root/.nyxd/bob_mnemonic; echo "$PASSWORD"; echo "$PASSWORD") | nyxd keys add bob --recover

    (echo "$PASSWORD";sleep 3;yes) | nyxd tx staking create-validator \
      --amount=1000000000unyx \
      --pubkey=$(nyxd tendermint show-validator) \
      --moniker=bob \
      --chain-id=nymtest-1 \
      --commission-rate="0.10" \
      --commission-max-rate="0.20" \
      --commission-max-change-rate="0.01" \
      --min-self-delegation="1" \
      --gas="auto" \
      --gas-adjustment=1.15 \
      --gas-prices="0.0025unyx" \
      --from=bob \
      --node=tcp://10.0.0.2:26657
    sleep 3
  else
    echo "Secondary Validator already initialized, starting with the existing configuration."
    echo "If you want to re-init the validator, destroy the existing container"
  fi
	nyxd start
else
	echo "Wrong command. Usage: ./$0 [genesis/secondary]"
fi
