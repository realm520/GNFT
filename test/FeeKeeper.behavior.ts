import { expect } from "chai";

export function shouldBehaveLikeFeeKeeper(): void {
  it("check initial value", async function () {
    expect(await this.feeKeeper.connect(this.signers.admin).checkFee(this.signers.admin.address)).to.equal(0);

  });

  it("mulitiple feeKeepers", async function () {
    await this.feeKeeper.addFeeKeeper(this.signers.author.address, 500);
    await this.feeKeeper.addFeeKeeper(this.signers.admin.address, 500);
    await this.feeKeeper.addFeeKeeper(this.signers.platform.address, 900);
    await this.feeKeeper.removeKeeper(this.signers.admin.address);
    const feeKeeper = await this.feeKeeper.feeInfo(1);
    expect(feeKeeper.ratio).to.equal(900);
    expect(feeKeeper.keeper).to.equal(this.signers.platform.address);
  });

  it("set author fee", async function () {
     await expect(this.feeKeeper.setAuthorTokenFee(this.nft.address, 1, this.signers.author.address, 200)).to.be.revertedWith("ERC721: owner query for nonexistent token");
     //await expect(this.nft.mint(this.signers.admin.address, , 500)).to.be.revertedWith("setAuthorTokenFee: invalid author address.");
     await expect(this.nft.mint(this.signers.admin.address, this.signers.author.address, 10000)).to.be.revertedWith("setAuthorTokenFee: invalid author ratio.");
     await this.nft.mint(this.signers.admin.address, this.signers.author.address, 500);
     await expect(this.feeKeeper.setAuthorTokenFee(this.nft.address, 0, this.signers.author.address, 200)).to.be.revertedWith("setAuthorTokenFee: change author fee not permitted.");
  });

  it("mint sell buy transfer", async function () {
    // mint nft to author
    await this.feeKeeper.addFeeKeeper(this.signers.admin.address, 100);
    await this.feeKeeper.addFeeKeeper(this.signers.platform.address, 300);
    await this.nft.mint(this.signers.author.address, this.signers.author.address, 500);
    expect(await this.nft.ownerOf(0)).to.be.eq(this.signers.author.address);
    // author sell nft
    await this.nft.connect(this.signers.author).approve(this.ex.address, 0);
    await expect(this.ex.connect(this.signers.platform).sellNFT(0, 10000)).to.be.revertedWith("sellNFT: Sender is not owner of given tokenid.");
    await this.ex.connect(this.signers.author).sellNFT(0, 10000);
    expect(await this.ex.getSellPrice(0)).to.be.eq(10000);
    // buyer buy nft
    await this.usdt.connect(this.signers.buyer).approve(this.ex.address, 1000000);
    await this.ex.connect(this.signers.buyer).buyNFT(0);
    expect(await this.nft.ownerOf(0)).to.be.eq(this.signers.buyer.address);
    expect(await this.feeKeeper.checkFee(this.signers.admin.address)).to.equal(100);
    expect(await this.feeKeeper.checkFee(this.signers.author.address)).to.equal(500);
    expect(await this.feeKeeper.checkFee(this.signers.platform.address)).to.equal(300);
    expect(await this.usdt.balanceOf(this.feeKeeper.address)).to.be.eq(900);
    expect(await this.usdt.balanceOf(this.signers.author.address)).to.be.eq(9100);
    // buyer sell nft
    await this.nft.connect(this.signers.buyer).approve(this.ex.address, 0);
    await this.ex.connect(this.signers.buyer).sellNFT(0, 20000);
    // admin buy nft
    await this.usdt.connect(this.signers.admin).approve(this.ex.address, 1000000);
    await this.ex.connect(this.signers.admin).buyNFT(0);
    expect(await this.feeKeeper.checkFee(this.signers.admin.address)).to.equal(300);
    expect(await this.feeKeeper.checkFee(this.signers.author.address)).to.equal(1500);
    expect(await this.feeKeeper.checkFee(this.signers.platform.address)).to.equal(900);
    expect(await this.usdt.balanceOf(this.feeKeeper.address)).to.be.eq(2700);
    // admin transfer nft to platform (fail)
    await expect(this.nft.transferFrom(this.signers.admin.address, this.signers.platform.address, 0)).to.be.revertedWith("checkPrice: insufficient balance for last fee.");
    // admin transfer nft to buyer
    await this.nft.transferFrom(this.signers.admin.address, this.signers.buyer.address, 0);
    expect(await this.usdt.allowance(this.signers.buyer.address, this.ex.address)).to.be.eq(988200);
  });

}

