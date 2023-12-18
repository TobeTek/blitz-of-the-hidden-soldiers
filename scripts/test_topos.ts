import { ethers } from "hardhat";

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;

  let pAddress = "0xC9C17e20642a48D2Ece933AEdA7c5d1D7DD8f2F5";

//   const lockedAmount = ethers.("0.001");

  
//  let [owner] = await ethers.getSigners();
 let bal = await ethers.provider.getBalance(pAddress);
 console.log("Balance is: ", bal);
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
