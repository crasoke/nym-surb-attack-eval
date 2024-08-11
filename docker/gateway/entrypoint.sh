#!/bin/sh
while ! [ -f "/bin_volume/nym-node" ] || ! [ -s "/nyx_volume/${GATEWAY_NAME}_mnemonic" ]; do
  sleep 1
done

until curl --output /dev/null --silent --head --fail http://10.0.0.99/v1/api-status/health; do
  echo "Waiting for nym API..."
  sleep 5
done

if [ ! -f "/root/nym-node" ]; then
  cp /bin_volume/nym-node /bin_volume/nym-cli /root

  /root/nym-node run --mode $GATEWAY_NAME --id $GATEWAY_NAME --nym-api-urls http://10.0.0.99 --nyxd-urls http://10.0.0.2:26657 --mnemonic "$(cat /nyx_volume/${GATEWAY_NAME}_mnemonic)" --public-ips $(hostname -i) --accept-operator-terms-and-conditions --init-only

  IDENTITY_KEY=$(/root/nym-node bonding-information --id $GATEWAY_NAME | grep "Identity Key:" | sed 's/Identity Key: //')
  SPHINX_KEY=$(/root/nym-node bonding-information --id $GATEWAY_NAME | grep "Sphinx Key:" | sed 's/Sphinx Key: //')
  VERSION=$(/root/nym-node bonding-information --id $GATEWAY_NAME | grep "Version:" | sed 's/Version: //')
  SIGN_PAYLOAD=$(/root/nym-cli mixnet operators gateway create-gateway-bonding-sign-payload --host $(hostname -i) --sphinx-key $SPHINX_KEY --identity-key $IDENTITY_KEY --version $VERSION --amount 1000000000 --mnemonic "$(cat /nyx_volume/${GATEWAY_NAME}_mnemonic)" --location "ger" --nyxd-url http://10.0.0.2:26657 --mixnet-contract-address "$(cat /nyx_volume/mixnet_contract_address)")

  SIGNATURE=$(/root/nym-node sign --id $GATEWAY_NAME --contract-msg $SIGN_PAYLOAD | tail -n 1)

  /root/nym-cli mixnet operators gateway bond --host $(hostname -i) --sphinx-key $SPHINX_KEY --identity-key $IDENTITY_KEY --version $VERSION --amount 1000000000 --mnemonic "$(cat /nyx_volume/${GATEWAY_NAME}_mnemonic)" --nyxd-url http://10.0.0.2:26657 --mixnet-contract-address "$(cat /nyx_volume/mixnet_contract_address)" --mix-port 1789 --signature $SIGNATURE --location "ger"
fi

/root/nym-node run --mode $GATEWAY_NAME --id $GATEWAY_NAME --nym-api-urls http://10.0.0.99 --nyxd-urls http://10.0.0.2:26657 --mnemonic "$(cat /nyx_volume/${GATEWAY_NAME}_mnemonic)" --public-ips $(hostname -i) --accept-operator-terms-and-conditions