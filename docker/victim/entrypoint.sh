#!/bin/sh
while ! [ -f "/bin_volume/nym-client" ] || ! [ -s "/nyx_volume/mixnet_contract_address" ] || ! [ -s "/nyx_volume/vesting_contract_address" ]; do
  sleep 1
done

cp -r /bin_volume/nym-client /bin_volume/nym-network-requester /bin_volume/nym-socks5-client /root/

until curl --output /dev/null --silent --head --fail http://10.0.0.99/v1/api-status/health; do
  echo "Waiting for nym API..."
  sleep 10
done

while [ "$(curl -s http://10.0.0.99/v1/mixnodes/active)" = "[]" ]; do
    echo "Waiting for Mixnodes to be selected..."
    sleep 20
done

if [ ! -s "/root/.nym/clients/$CLIENT_NAME/config/config.toml" ]; then
  /root/nym-client init --id $CLIENT_NAME --nym-apis http://10.0.0.99 --nyxd-urls http://10.0.0.2:26657 --gateway "$(cat /nyx_volume/${GATEWAY_NAME}_id)" | sed -n 's/^Address of this client: //p' > /nyx_volume/${CLIENT_NAME}_address
fi
sleep 30

if [ $CLIENT_NAME = "victim" ]; then
  /root/nym-client run --id $CLIENT_NAME &
  sleep 30
  cd /root/surb_attack/
  cargo run
  tail -f /dev/null
else
  # sleep $(( $(echo ${CLIENT_NAME} | tail -c 2) * 30 ))
  /root/nym-client run --id $CLIENT_NAME
fi