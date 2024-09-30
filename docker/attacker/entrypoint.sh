#!/bin/sh
while ! [ -f "/bin_volume/nym-client-attacker" ] || ! [ -s "/nyx_volume/mixnet_contract_address" ] || ! [ -s "/nyx_volume/vesting_contract_address" ]; do
  sleep 1
done

cp /bin_volume/nym-client-attacker /bin_volume/nym-network-requester /bin_volume/nym-socks5-client /root/

until curl --output /dev/null --silent --head --fail http://10.0.0.99/v1/api-status/health; do
  echo "Waiting for nym API..."
  sleep 10
done

while [ "$(curl -s http://10.0.0.99/v1/mixnodes/active)" = "[]" ]; do
    echo "Waiting for Mixnodes to be selected..."
    sleep 20
done

if [ ! -s "/root/.nym/clients/$CLIENT_NAME/config/config.toml" ]; then
  /root/nym-client-attacker init --id $CLIENT_NAME --nym-apis http://10.0.0.99 --nyxd-urls http://10.0.0.2:26657 --gateway "$(cat /nyx_volume/${GATEWAY_NAME}_id)" | sed -n 's/^Address of this client: //p' > /nyx_volume/${CLIENT_NAME}_address

  sed -i "s/average_packet_delay = '50ms'/average_packet_delay = '0ms'/g" /root/.nym/clients/attacker1/config/config.toml
  sed -i "s/message_sending_average_delay = '20ms'/message_sending_average_delay = '0ms'/g" /root/.nym/clients/attacker1/config/config.toml
  sed -i "s/average_ack_delay = '50ms'/average_ack_delay = '0ms'/g" /root/.nym/clients/attacker1/config/config.toml
fi
sleep 30
/root/nym-client-attacker run --id $CLIENT_NAME --no-cover &

cd /root/surb_attack/
TEST_START_TIME=$(cat /nyx_volume/time)

case $CLIENT_NAME in

  attacker1)
    sed -i "s/3000/100/g" /root/surb_attack/src/main.rs
    cargo build
    sleep $(($TEST_START_TIME + 600 - $(date +%s)))
    cargo run
    sleep 300
    ;;

  attacker2)
    sed -i "s/3000/500/g" /root/surb_attack/src/main.rs
    cargo build
    sleep $(($TEST_START_TIME + 1200 - $(date +%s)))
    cargo run
    sleep 300
    ;;

  attacker3)
    sed -i "s/3000/1000/g" /root/surb_attack/src/main.rs
    cargo build
    sleep $(($TEST_START_TIME + 1800 - $(date +%s)))
    cargo run
    sleep 300
    ;;

  attacker4)
    sed -i "s/3000/2000/g" /root/surb_attack/src/main.rs
    cargo build
    sleep $(($TEST_START_TIME + 2400 - $(date +%s)))
    cargo run
    sleep 300
    ;;

  attacker5)
    sed -i "s/3000/5000/g" /root/surb_attack/src/main.rs
    cargo build
    sleep $(($TEST_START_TIME + 3000 - $(date +%s)))
    cargo run
    sleep 600
    ;;

  *)
    echo "unknown"
    ;;
esac