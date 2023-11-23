# Blitz of the Hidden Soldiers

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/TobeTek/blitz-of-the-hidden-soldiers)

Blitz of The Hidden Soldiers (BoTHS), a game of incomplete information, blends the strategic depth of traditional chess with the intrigue of hidden moves and pieces. This project will implement a blind chess game on the Topos testnet, leveraging ZKPs to obscure board positions. The primary collectible, donums (Latin for gifts), bestow unique abilities upon players. In this immersive gaming experience, each player is distinctly identified by their public blockchain address, ensuring transparency and security throughout the gameplay.

## Installation

Install hardhat and development dependencies with npm

```bash
  npm i
```

Follow [the online guide to install circom](https://docs.circom.io/getting-started/installation/)
    
## Running Tests

Try running some of the following tasks:

1. To check if `circom` are valid:
```shell
./scripts/check_circom.sh
```

2. General HardHat/Smart Contract tests
```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```



## Directory Structure
 - `src/contracts`: Solidity Smart contracts
    - `src/contracts/pieces`: Solidity Smart contracts for individual chess pieces. Each chess piece has a unique set of legal moves and behaviour.
 - `src/circuits`: Circom arithmetic circuits
 - `scripts`: Hardhat scripts and regular bash scripts for regular tasks like compiling, testing etc.

Read the [DevLog](https://tobetek.github.io/blitz-of-the-hidden-soldiers-devlog)

