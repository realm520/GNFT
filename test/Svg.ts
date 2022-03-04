import hre from "hardhat";
import { Artifact } from "hardhat/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

import { XPlanetSVG } from "../typechain/XPlanetSVG";
import { Signers } from "../types";
import { shouldBehaveLikeSVG } from "./Svg.behavior";

const { deployContract } = hre.waffle;

describe("Unit tests", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers: SignerWithAddress[] = await hre.ethers.getSigners();
    this.signers.admin = signers[0];
  });

  describe("XPlanetSVG", function () {
    beforeEach(async function () {
      const svgArtifact: Artifact = await hre.artifacts.readArtifact("XPlanetSVG");
      this.svg = <XPlanetSVG>await deployContract(this.signers.admin, svgArtifact, []);
    });

    shouldBehaveLikeSVG();
  });
});

