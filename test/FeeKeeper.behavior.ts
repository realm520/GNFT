import { expect } from "chai";

export function shouldBehaveLikeFeeKeeper(): void {
  it("check initial value", async function () {
    expect(await this.feeKeeper.connect(this.signers.admin).checkFee(this.signers.admin.address)).to.equal(0);

  });

  it("setTokenFeeRate", async function () {
    await this.feeKeeper.setTokenFeeRate(1, 100);
    expect(await this.feeKeeper.connect(this.signers.admin).getTokenFeeRate(1)).to.equal(100);
  });

  it("assign fee", async function () {
    await this.feeKeeper.addFeeKeeper(this.signers.author.address, 500);
    await this.feeKeeper.addFeeKeeper(this.signers.admin.address, 500);
    await this.feeKeeper.addFeeKeeper(this.signers.platform.address, 9000);
    await this.feeKeeper.assignFee(100);
    expect(await this.feeKeeper.checkFee(this.signers.admin.address)).to.equal(5);
    expect(await this.feeKeeper.checkFee(this.signers.author.address)).to.equal(5);
    expect(await this.feeKeeper.checkFee(this.signers.platform.address)).to.equal(90);
  });

  it("mulitiple feeKeepers", async function () {
    await this.feeKeeper.addFeeKeeper(this.signers.author.address, 500);
    await this.feeKeeper.addFeeKeeper(this.signers.admin.address, 500);
    await this.feeKeeper.addFeeKeeper(this.signers.platform.address, 9000);
    await this.feeKeeper.removeKeeper(this.signers.admin.address);
    const feeKeeper = await this.feeKeeper.feeInfo(1);
    expect(feeKeeper.ratio).to.equal(9000);
    expect(feeKeeper.keeper).to.equal(this.signers.platform.address);
  });

}

