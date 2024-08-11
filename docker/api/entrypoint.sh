#!/bin/sh
while ! [ -f "/bin_volume/nym-api" ] || ! [ -s "/nyx_volume/alice_mnemonic" ]; do
    sleep 1
done

sleep 10

if [ ! -f "/root/.nym/nym-api/api/config/config.toml" ]; then
  cp /bin_volume/nym-api /root
  /root/nym-api init --id api --mnemonic "$(cat /nyx_volume/alice_mnemonic)" -r -m --nyxd-validator http://10.0.0.2:26657 --announce-address http://10.0.0.99
else
  echo "Nym binary already initiated."
  echo "If you want to re-initate, delete the container."
fi

nginx
/root/nym-api run --id api