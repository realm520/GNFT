import "@nomiclabs/hardhat-web3";
import { Signer } from "@ethersproject/abstract-signer";
import { task } from "hardhat/config";

import { TASK_ACCOUNTS } from "./task-names";

task(TASK_ACCOUNTS, "Prints the list of accounts", async (_taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    const balance = await hre.web3.eth.getBalance(await account.getAddress());
    console.log(await account.getAddress(), "\t", hre.web3.utils.fromWei(balance, "ether"), "ETH");
  }
});
