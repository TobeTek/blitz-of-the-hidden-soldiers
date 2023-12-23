import "@nomicfoundation/hardhat-toolbox";
import { configDotenv } from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import {
  HardhatNetworkAccountUserConfig,
  HttpNetworkAccountsConfig,
  HttpNetworkAccountsUserConfig,
  NetworksUserConfig,
} from "hardhat/types";

import "hardhat-deploy";
import "tsconfig-paths/register";
// import "hardhat-circom";

configDotenv();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.22",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1,
      },
      outputSelection: {
        "*": {
          "*": ["storageLayout"],
        },
      },
      viaIR: true,
    },
  },
  paths: {
    sources: "./src/contracts",
    tests: "./src/test",
  },
  defaultNetwork: "hardhat",
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  networks: {
    hardhat: {
      chainId: 31337,
    },
    topos: {
      chainId: 2359,
      url: "https://rpc.topos-subnet.testnet-1.topos.technology",
      accounts: [
        process.env.DEV_ACCOUNT_PRIVATE_KEY,
      ] as HttpNetworkAccountsUserConfig,
    },
  },
  // circom: {
  //   // (optional) Base path for input files, defaults to `./circuits/`
  //   inputBasePath: "./src/circuits",
  //   // (required) The final ptau file, relative to inputBasePath, from a Phase 1 ceremony
  //   ptau: "https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_15.ptau",
  //   // (required) Each object in this array refers to a separate circuit
  //   circuits: [{ name: "division", protocol: "groth16" }],
  // },
};

export default config;
