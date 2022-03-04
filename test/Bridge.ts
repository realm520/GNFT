import hre from "hardhat";
import { Artifact } from "hardhat/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

import { Bridge } from "../typechain/Bridge";
import { Signers } from "../types";
import { USDT } from "../typechain/USDT";
import { shouldBehaveLikeBridge } from "./Bridge.behavior";

const { deployContract } = hre.waffle;

describe("Unit tests", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers: SignerWithAddress[] = await hre.ethers.getSigners();
    this.signers.admin = signers[0];
    this.op1 = signers[1];
    this.op2 = signers[2];
    this.user = signers[3];
  });

  describe("DccBridge", function () {
    beforeEach(async function () {
        const usdtArtifact: Artifact = await hre.artifacts.readArtifact("USDT");
        this.usdt = <USDT>await deployContract(this.signers.admin, usdtArtifact, []);
        const svgArtifact: Artifact = await hre.artifacts.readArtifact("Bridge");
      this.bridge = <Bridge>await deployContract(this.signers.admin, svgArtifact, []);
    });

    shouldBehaveLikeBridge();
  });
});

