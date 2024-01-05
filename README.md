# Blitz of the Hidden Soldiers

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/TobeTek/blitz-of-the-hidden-soldiers)

Blitz of The Hidden Soldiers (BoTHS), a game of incomplete information, blends the strategic depth of traditional chess with the intrigue of hidden moves and pieces. This project will implement a blind chess game on the Topos testnet, leveraging ZKPs to obscure board positions. The primary collectible, donums (Latin for gifts), bestow unique abilities upon players. In this immersive gaming experience, each player is distinctly identified by their public blockchain address, ensuring transparency and security throughout the gameplay.

## Installation

Install hardhat and development dependencies with npm

```bash
  npm i
```

or with `yarn`

```bash
yarn install
```

Follow [the online guide to install circom](https://docs.circom.io/getting-started/installation/)

## Running Tests

Try running some of the following tasks:

1. To compile all `circom` circuits and generate corresponding `zkeys`:

```shell
./scripts/compile_circom.sh
```

2. General HardHat/Smart Contract Commands
   **Run Tests**

```shell
npx hardhat test

```

**Run a local node**

```bash
npx hardhat node --deploy --export-all deployments.json
```

**Deploy** (using the [hardhat-deploy]
(https://github.com/wighawag/hardhat-deploy) plugin)

```bash
npx hardhat deploy --export-all --network [network-name]
```

**Upload smart contract addresses and their corresponding ABI to Firebase**

```bash
npx hardhat run scripts/writeDeploymentsToFirebase.ts
```

## Directory Structure

- `src/contracts`: Solidity Smart contracts
  - `ChessPieceCollection`: ERC1155 Game Collectible contract
  - `GameManager.sol`: Create games, validate piece formations, and token stakes.
  - `ChessGame.sol`: All the chess-specific logic you'd expect. Was that a checkmate?
  - `src/circom_verifiers`: Solidity verifier contracts for circom circuits.
  - `src/contracts/mocks`: Mock smart contracts for testing.
- `src/circuits`: Circom circuits
- `src/tests`: Tests!

# Interact with the Smart Contracts on the Topos Testnet

- **ChessPieceCollection.sol**: [0xD42a0ecFbDA16f22aA05c83b68EA4a673C53FA23](https://topos.blockscout.testnet-1.topos.technology/address/0xD42a0ecFbDA16f22aA05c83b68EA4a673C53FA23)
- **GameManager.sol**: [0x746dF08DCC2B6Ef57cC996f128933aB831251474](https://topos.blockscout.testnet-1.topos.technology/address/0x746dF08DCC2B6Ef57cC996f128933aB831251474)
- **PieceMotionPlonkVerifier.sol**: [0x462F40693289309b0292fdbFC9dbF484EEc6e64E](https://topos.blockscout.testnet-1.topos.technology/address/0x462F40693289309b0292fdbFC9dbF484EEc6e64E)
- **PlayerVisionPlonkVerifier.sol**: [0xE2B8d66C60f0f3B725078D00E3FEf5BbDD77817a](https://topos.blockscout.testnet-1.topos.technology/address/0xE2B8d66C60f0f3B725078D00E3FEf5BbDD77817a)
- **RevealBoardPositionsPlonkVerifier.sol**: [0x491CebC71299D816870b76451df55419226a4485](https://topos.blockscout.testnet-1.topos.technology/address/0x491CebC71299D816870b76451df55419226a4485)

> Read the [DevLog](https://tobetek.github.io/blitz-of-the-hidden-soldiers-devlog)
