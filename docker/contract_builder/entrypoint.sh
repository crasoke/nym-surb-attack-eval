#!/bin/sh
# For why and stuff look at https://github.com/CosmWasm/optimizer
if [ ! -f "/contract_volume/mixnet_contract.wasm" ]; then
  cd /app/nym/contracts/mixnet
  rustup target add wasm32-unknown-unknown
  RUSTFLAGS='-C link-arg=-s' cargo build --release --lib --target=wasm32-unknown-unknown --locked --features=contract-testing,schema-gen --no-default-features
  wasm-opt -Os --signext-lowering /app/nym/contracts/target/wasm32-unknown-unknown/release/mixnet_contract.wasm -o /contract_volume/mixnet_contract.wasm
else
  echo "Mixnet contract already built, if you want to rebuilt contract, delete contract_volume/mixnet_contract.wasm"
fi

if [ ! -f "/contract_volume/vesting_contract.wasm" ]; then
  cd /app/nym/contracts/vesting
  rustup target add wasm32-unknown-unknown
  RUSTFLAGS='-C link-arg=-s' cargo build --release --lib --target=wasm32-unknown-unknown --locked --features=schema-gen  --no-default-features
  wasm-opt -Os --signext-lowering /app/nym/contracts/target/wasm32-unknown-unknown/release/vesting_contract.wasm -o /contract_volume/vesting_contract.wasm
else
  echo "Vesting contract already built, if you want to rebuilt contract, delete contract_volume/vesting_contract.wasm"
fi