import { Contract, ContractFactory } from "ethers";
// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main(): Promise<void> {
  // Hardhat always runs the compile task when running scripts through it.
  // If this runs in a standalone fashion you may want to call compile manually
  // to make sure everything is compiled
  // await run("compile");

  // We get the contract to deploy
//   const USDT: ContractFactory = await ethers.getContractFactory("USDT");
//   const usdt: Contract = await USDT.deploy();
//   await usdt.deployed();
//   console.log("USDT deployed to: ", usdt.address);

  const Bridge: ContractFactory = await ethers.getContractFactory("Bridge");
  const bridge: Contract = await Bridge.deploy();
  await bridge.deployed();
  console.log("Bridge deployed to: ", bridge.address);

//   await bridge.setOperator("0xf1dA35bD2c395AB93dC27D5b45aCCa61E9Ed245b", 1);
//   await bridge.setOperator("0x60CD500253a48eCd263e2eCC85727ab53E12EbCd", 2);
//   await bridge.transferOwnership('0xa1f3b2f333E426801b50F57d027B26F2f280dF92');
  console.log("Bridge initialized.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
