import { HardhatUserConfig } from "hardhat/config";
import { NetworksUserConfig } from "hardhat/types";
import { HardhatNetworkAccountUserConfig } from "hardhat/types";
import {
  HttpNetworkAccountsConfig,
  HttpNetworkAccountsUserConfig,
} from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";

import "tsconfig-paths/register";
// import "hardhat-circom";

const config: HardhatUserConfig = {
  solidity: {
    version:"0.8.22",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1,
      },
      "viaIR": true,
    }
  },
  paths: {
    sources: "./src/contracts",
    tests: "./src/test",
  },
  networks: {
    topos: {
      chainId: 2359,
      url: "https://rpc.topos-subnet.testnet-1.topos.technology",
      accounts: [
        "c3254734b203f0bcd02e6400d5f27f4f962c000e491ddd88f96d8e4855110b1c"
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
