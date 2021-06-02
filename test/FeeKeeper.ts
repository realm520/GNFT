import hre from "hardhat";
import { Artifact } from "hardhat/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

import { FeeKeeper } from "../typechain/FeeKeeper";
import { USDT } from "../typechain/USDT";
import { Signers } from "../types";
import { shouldBehaveLikeFeeKeeper } from "./FeeKeeper.behavior";

const { deployContract } = hre.waffle;

describe("Unit tests", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers: SignerWithAddress[] = await hre.ethers.getSigners();
    this.signers.admin = signers[0];
    this.signers.platform = signers[1];
    this.signers.author = signers[2];
  });

  describe("FeeKeeper", function () {
    beforeEach(async function () {
      const usdtArtifact: Artifact = await hre.artifacts.readArtifact("USDT");
      this.usdt = <USDT>await deployContract(this.signers.admin, usdtArtifact, []);
      const feeKeeperArtifact: Artifact = await hre.artifacts.readArtifact("FeeKeeper");
      this.feeKeeper = <FeeKeeper>await deployContract(this.signers.admin, feeKeeperArtifact, [this.usdt.address]);
    });

    shouldBehaveLikeFeeKeeper();
  });
});

