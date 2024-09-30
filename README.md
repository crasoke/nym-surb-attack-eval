# Nym SURB attack evaluation

This is a test for an attack on the [Nym Network](https://github.com/nymtech/nym) in Docker. It creates a custom cosmos blockchain, uploads the nym smart contract, and then also launches the nym network with mixnodes, gateway, api, and clients. It then starts the attack using SURBs. It will create graphs showing the results.

It will build and run the following containers:

* A genesis validator
* A secondary validator
* A contract builder that compiles the nym vesting and mixnet smart contracts
* A contract uploader that uploads and instantiates the smart contracts to the Cosmos blockchain.
* A binary builder that builds the nym binaries with modified smart contract addresses
* A nym API
* 3 mix nodes
* 1 entry gateway
* 7 nym clients

# Requirements

* Docker
* Docker compose
* python3
* python3-pandas
* python3-matplotlib
* tshark
* gawk/awk

# Quickstart

To build and run the Docker environment, simply run
```bash
./test_and_create_graph.sh
```
It will build and run all of the above containers. This may take a while. Afteer that it will start the attack with different amount of SURBs.