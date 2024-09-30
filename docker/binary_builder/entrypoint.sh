#!/bin/sh
if [ ! -f "/bin_volume/nym-api" ] || [ ! -f "/bin_volume/nym-cli" ] || [ ! -f "/bin_volume/nym-client" ] || [ ! -f "/bin_volume/nym-node" ]; then
  # check if smart contract address file exists + is greater than zero and therefore instantiated
  while ! [ -s "/nyx_volume/mixnet_contract_address" ] || ! [ -s "/nyx_volume/vesting_contract_address" ]; do
    sleep 1
  done
  # replace contract addresses
  find nym -type f -exec sed -i "s/n17srjznxl9dvzdkpwpw24gg668wc73val88a6m5ajg6ankwvz9wtst0cznr/$(cat /nyx_volume/mixnet_contract_address)/g" {} \;
  find nym -type f -exec sed -i "s/n1nc5tatafv6eyq7llkr2gv50ff9e22mnf70qgjlv737ktmt4eswrq73f2nw/$(cat /nyx_volume/vesting_contract_address)/g" {} \;
  #make loggin in gateway easier
  sed -i 's/trace!("Pushed received packet to {client_address}")/info!("Pushed received packet to {client_address}")/g' nym/gateway/src/node/mixnet_handling/receiver/connection_handler.rs
  # build binaries and copy them to the bin_volume
  cd nym
  cargo build --release -p "nym-api" -p "nym-node" -p "nym-cli" -p "nym-client" -p "nym-network-requester" -p "nym-socks5-client"
  cp /app/nym/target/release/nym-api /app/nym/target/release/nym-node /app/nym/target/release/nym-cli /app/nym/target/release/nym-client /app/nym/target/release/nym-network-requester /app/nym/target/release/nym-socks5-client /bin_volume

  cp /root/mod.rs common/client-core/src/client/replies/reply_controller/mod.rs
  # cp /root/handler.rs clients/native/src/websocket/handler.rs
  # cp /root/requests.rs clients/native/websocket-requests/src/requests.rs
  find . -type f -exec sed -i \
  -e "s/const DEFAULT_MINIMUM_REPLY_SURB_STORAGE_THRESHOLD: usize = 10;/const DEFAULT_MINIMUM_REPLY_SURB_STORAGE_THRESHOLD: usize = 30;/g" \
    -e "s/const DEFAULT_MAXIMUM_REPLY_SURB_STORAGE_THRESHOLD: usize = 200;/const DEFAULT_MAXIMUM_REPLY_SURB_STORAGE_THRESHOLD: usize = 6000;/g" {} \
    -e "s/const DEFAULT_MINIMUM_REPLY_SURB_REQUEST_SIZE: u32 = 10;/const DEFAULT_MINIMUM_REPLY_SURB_REQUEST_SIZE: u32 = 499;/g" \
    -e "s/const DEFAULT_MAXIMUM_REPLY_SURB_REQUEST_SIZE: u32 = 100;/const DEFAULT_MAXIMUM_REPLY_SURB_REQUEST_SIZE: u32 = 499;/g" {} \;
  # find . -type f -exec sed -i \
  #   -e "s/const DEFAULT_MINIMUM_REPLY_SURB_STORAGE_THRESHOLD: usize = 10;/const DEFAULT_MINIMUM_REPLY_SURB_STORAGE_THRESHOLD: usize = 5000;/g" \
  #   -e "s/const DEFAULT_MAXIMUM_REPLY_SURB_STORAGE_THRESHOLD: usize = 200;/const DEFAULT_MAXIMUM_REPLY_SURB_STORAGE_THRESHOLD: usize = 6000;/g" {} \
  #   -e "s/const DEFAULT_MINIMUM_REPLY_SURB_REQUEST_SIZE: u32 = 10;/const DEFAULT_MINIMUM_REPLY_SURB_REQUEST_SIZE: u32 = 499;/g" \
  #   -e "s/const DEFAULT_MAXIMUM_REPLY_SURB_REQUEST_SIZE: u32 = 100;/const DEFAULT_MAXIMUM_REPLY_SURB_REQUEST_SIZE: u32 = 499;/g" {} \;

  cargo build --release -p "nym-client"
  cp /app/nym/target/release/nym-client /bin_volume/nym-client-attacker
else
  echo "Nym binary already compiled."
  echo "If you want to re-compile, delete the nym binaries in ./data/bin_volume/"
fi