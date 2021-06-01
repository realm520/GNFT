import { expect } from "chai";

export function shouldBehaveLikeFeeKeeper(): void {
  it("check initial value", async function () {
    expect(await this.feeKeeper.connect(this.signers.admin).checkFee(this.signers.admin.address)).to.equal(0);

    //await this.greeter.setGreeting("Hola, mundo!");
    //expect(await this.greeter.connect(this.signers.admin).greet()).to.equal("Hola, mundo!");
  });
}

