import { expect } from "chai";
import { ethers } from "hardhat"

export function shouldBehaveLikeBridge(): void {
    it("normalWithdraw", async function () {
        const provider = ethers.provider;
        await this.signers.admin.sendTransaction({
            to: this.bridge.address,
            value: ethers.utils.parseEther("1.0"),
          });
        await this.usdt.connect(this.signers.admin).transfer(this.bridge.address, 100000);
        expect(await provider.getBalance(this.bridge.address)).to.be.equal(ethers.utils.parseEther("1.0"));
        expect(await this.usdt.balanceOf(this.bridge.address)).to.be.equal(100000);
        var etherBefore = await provider.getBalance(this.signers.admin.address);
        expect(await this.usdt.balanceOf(this.signers.admin.address)).to.be.equal("99999999999999999999999900000");
        await this.bridge.connect(this.signers.admin).withdraw(this.usdt.address);
        expect(await provider.getBalance(this.bridge.address)).to.be.equal(0);
        expect(await this.usdt.balanceOf(this.bridge.address)).to.be.equal(0);
        var etherAfter = await provider.getBalance(this.signers.admin.address);
        expect(etherAfter.sub(etherBefore)).to.gt(ethers.utils.parseEther("0.99"));
        expect(await this.usdt.balanceOf(this.signers.admin.address)).to.be.equal("100000000000000000000000000000");
      });
    
      it("normalIn", async function () {
    await this.bridge.connect(this.signers.admin).setOperator(this.op1.address, 1);
    await this.bridge.connect(this.signers.admin).setOperator(this.op2.address, 2);
    await this.usdt.approve(this.bridge.address, 10000000);
    await this.bridge.connect(this.signers.admin).depositToken(this.usdt.address, 10000);
    const inTx0 = await this.bridge.getIn(0);
    expect(inTx0.from).to.be.equal(this.signers.admin.address);
    expect(inTx0.value).to.be.equal(10000);
    await this.bridge.connect(this.signers.admin).depositEther({
        gasLimit: 9999999,
        value: 20000
    });
    const inTx1 = await this.bridge.getIn(1);
    expect(inTx1.from).to.be.equal(this.signers.admin.address);
    expect(inTx1.value).to.be.equal(20000);
    await expect(this.bridge.getIn(2)).to.be.revertedWith('Invalid offset');
  });

  it("normalEtherOut", async function () {
    await this.bridge.connect(this.signers.admin).setOperator(this.op1.address, 1);
    await this.bridge.connect(this.signers.admin).setOperator(this.op2.address, 2);
    await this.signers.admin.sendTransaction({
        to: this.bridge.address,
        value: ethers.utils.parseEther("1.0"),
      });
    const provider = ethers.provider;
    expect(await provider.getBalance(this.bridge.address)).to.be.equal(ethers.utils.parseEther("1.0"));
    expect(await this.bridge.getBalance()).to.be.equal(ethers.utils.parseEther("1.0"));
    await this.bridge.connect(this.op1).sendEther(1, this.user.address, 10);
    await this.bridge.connect(this.op2).sendEther(1, this.user.address, 10);
    
    expect(await provider.getBalance(this.user.address)).to.be.equal("10000000000000000000010");
  });

  it("normalTokenOut", async function () {
    await this.bridge.connect(this.signers.admin).setOperator(this.op1.address, 1);
    await this.bridge.connect(this.signers.admin).setOperator(this.op2.address, 2);
    await this.usdt.connect(this.signers.admin).transfer(this.bridge.address, 100000);
    await this.bridge.connect(this.op1).sendToken(1, this.usdt.address, this.user.address, 10);
    await this.bridge.connect(this.op2).sendToken(1, this.usdt.address, this.user.address, 10);
    expect(await this.usdt.balanceOf(this.user.address)).to.be.equal(10);
  });

  it("normalPause", async function () {
    await this.bridge.connect(this.signers.admin).setOperator(this.op1.address, 1);
    await this.bridge.pause();
    await expect(this.bridge.connect(this.op1).sendToken(1, this.usdt.address, this.user.address, 10)).to.be.revertedWith('Pausable: paused');
    await this.bridge.unpause();
    await this.bridge.connect(this.op1).sendToken(1, this.usdt.address, this.user.address, 10);
  });

  it("errorCase", async function () {
    await expect(this.bridge.connect(this.signers.admin).setOperator(this.op1.address, 0)).to.be.revertedWith('Invalid index');
    await expect(this.bridge.connect(this.signers.admin).setOperator(this.op1.address, 3)).to.be.revertedWith('Invalid index');
    await expect(this.bridge.getIn(1)).to.be.revertedWith('Invalid offset');
    await expect(this.bridge.sendEther(1, this.user.address, 1)).to.be.revertedWith('Invalid operator');
    await this.bridge.connect(this.signers.admin).setOperator(this.op1.address, 1);
    await this.bridge.connect(this.signers.admin).setOperator(this.op2.address, 2);
    await expect(this.bridge.connect(this.op1).sendEther(1, this.user.address, 0)).to.be.revertedWith('Invalid value');
    await this.bridge.connect(this.op1).sendEther(2, this.user.address, 10);
    await expect(this.bridge.connect(this.op2).sendEther(2, this.user.address, 20)).to.be.revertedWith('Out record mismatch');
  });

  it("gasEstimate", async function () {
    await this.bridge.connect(this.signers.admin).setOperator(this.op1.address, 1);
    await this.bridge.connect(this.signers.admin).setOperator(this.op2.address, 2);
    var tx = await (this.bridge.connect(this.op1).sendEther(1, this.user.address, 1));
    var receipt = await tx.wait();
    expect(receipt.gasUsed).to.eq(98589);
    for (let i=2; i<100; ++i) {
        tx = await (this.bridge.connect(this.op1).sendEther(i, this.user.address, i));
        receipt = await tx.wait();
        console.log(receipt.gasUsed.toString());
        // expect(receipt.gasUsed).to.lt(100000);
        if (i % 100 == 0) {
            console.log(i);
        }
    }
    await this.usdt.approve(this.bridge.address, 100000000);
    for (let i=1; i<100; ++i) {
        tx = await (this.bridge.depositToken(this.usdt.address, i));
        receipt = await tx.wait();
        // expect(receipt.gasUsed).to.lt(100000);
        console.log(receipt.gasUsed.toString());
        tx = await (this.bridge.depositEther({
            gasLimit: 9999999,
            value: i
        }));
        receipt = await tx.wait();
        // expect(receipt.gasUsed).to.lt(100000);
        console.log(receipt.gasUsed.toString());
        expect(await this.bridge.getInLength()).to.be.equal(i*2);
        if (i % 100 == 0) {
            console.log(i);
        }
    }
  }).timeout(1000000);

  it("transferOwnership", async function () {
      expect(await this.bridge.owner()).to.be.equal(this.signers.admin.address);
      await this.bridge.connect(this.signers.admin).transferOwnership(this.user.address);
      expect(await this.bridge.owner()).to.be.equal(this.user.address);
  });
}
