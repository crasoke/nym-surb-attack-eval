#!/bin/sh
if [ ! -f "/bin_volume/nym-api" ] || [ ! -f "/bin_volume/nym-cli" ] || [ ! -f "/bin_volume/nym-client" ] || [ ! -f "/bin_volume/nym-node" ]; then
  # check if smart contract address file exists + is greater than zero and therefore instantiated
  while ! [ -s "/nyx_volume/mixnet_contract_address" ] || ! [ -s "/nyx_volume/vesting_contract_address" ]; do
    sleep 1
  done
  # replace contract addresses
  find nym -type f -exec sed -i "s/n17srjznxl9dvzdkpwpw24gg668wc73val88a6m5ajg6ankwvz9wtst0cznr/$(cat /nyx_volume/mixnet_contract_address)/g" {} \;
  find nym -type f -exec sed -i "s/n1nc5tatafv6eyq7llkr2gv50ff9e22mnf70qgjlv737ktmt4eswrq73f2nw/$(cat /nyx_volume/vesting_contract_address)/g" {} \;
  # build binaries and copy them to the bin_volume
  cd nym
  # cargo build --release --workspace
  cargo build --release -p "nym-api" -p "nym-node" -p "nym-cli" -p "nym-client"
  cp /app/nym/target/release/nym-api /app/nym/target/release/nym-node /app/nym/target/release/nym-cli /app/nym/target/release/nym-client /bin_volume
else
  echo "Nym binary already compiled."
  echo "If you want to re-compile, delete the nym binaries in ./data/bin_volume/"
fi