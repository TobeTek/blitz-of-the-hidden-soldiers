import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-circom";

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  paths: {
    sources: "./src/contracts",
    tests: "./src/test",
  },
};

export default config;
