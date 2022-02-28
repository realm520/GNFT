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
  const USDT: ContractFactory = await ethers.getContractFactory("USDT");
  const usdt: Contract = await USDT.deploy();
  await usdt.deployed();
  console.log("USDT deployed to: ", usdt.address);

  const Exchange: ContractFactory = await ethers.getContractFactory("GNFTExchange");
  const exchange: Contract = await Exchange.deploy();
  await exchange.deployed();
  console.log("GNFTExchange deployed to: ", exchange.address);

  const FeeKeeper: ContractFactory = await ethers.getContractFactory("FeeKeeper");
  const feeKeeper: Contract = await FeeKeeper.deploy(usdt.address);
  await feeKeeper.deployed();
  console.log("FeeKeeper deployed to: ", feeKeeper.address);

  const NFT: ContractFactory = await ethers.getContractFactory("GNFT");
  const nft: Contract = await NFT.deploy(exchange.address, feeKeeper.address);
  await nft.deployed();
  console.log("NFT deployed to: ", nft.address);

  exchange.setFeeContract(feeKeeper.address);
  exchange.setNftContract(nft.address);
  console.log("NFTExchange initialized.");
}


async function mock(): Promise<void> {
  const ERC20PermitMock: ContractFactory = await ethers.getContractFactory("ERC20PermitMock");
  const mock: Contract = await ERC20PermitMock.deploy("MSC", "MSC");
  await mock.deployed();
  console.log("ERC20PermitMock deployed to: ", mock.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
mock()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error(error);
    process.exit(1);
  });
