#!/bin/sh
while ! [ -f "/bin_volume/nym-client" ] || ! [ -s "/nyx_volume/mixnet_contract_address" ] || ! [ -s "/nyx_volume/vesting_contract_address" ]; do
  sleep 1
done

sleep 600

if [ ! -f "/root/nym-node" ]; then
  cp /bin_volume/nym-client /root/
  /root/nym-client init --id $CLIENT_NAME --nym-apis http://10.0.0.99
fi

/root/nym-client run --id $CLIENT_NAME