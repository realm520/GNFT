import hre from "hardhat";
import { Artifact } from "hardhat/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

import { FeeKeeper } from "../typechain/FeeKeeper";
import { GNFTExchange } from "../typechain/GNFTExchange";
import { GNFT } from "../typechain/GNFT";
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
    this.signers.buyer = signers[3];
  });

  describe("FeeKeeper", function () {
    beforeEach(async function () {
      const usdtArtifact: Artifact = await hre.artifacts.readArtifact("USDT");
      this.usdt = <USDT>await deployContract(this.signers.admin, usdtArtifact, []);
      const exArtifact: Artifact = await hre.artifacts.readArtifact("GNFTExchange");
      this.ex = <GNFTExchange>await deployContract(this.signers.admin, exArtifact, []);
      const feeKeeperArtifact: Artifact = await hre.artifacts.readArtifact("FeeKeeper");
      this.feeKeeper = <FeeKeeper>await deployContract(this.signers.admin, feeKeeperArtifact, [this.usdt.address]);
      const nftArtifact: Artifact = await hre.artifacts.readArtifact("GNFT");
      this.nft = <GNFT>await deployContract(this.signers.admin, nftArtifact, [this.ex.address, this.feeKeeper.address]);
      this.ex.setNftContract(this.nft.address);
      this.ex.setFeeContract(this.feeKeeper.address);
      this.usdt.transfer(this.signers.buyer.address, 100000000);
    });

    shouldBehaveLikeFeeKeeper();
  });
});

