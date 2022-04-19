const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");

function buildCreate2Address(creatorAddress, saltHex, byteCode) {
  //console.log(byteCode);
  //console.log(`0x${['ff',creatorAddress,saltHex,ethers.utils.keccak256(byteCode)].map(x => x.replace(/0x/, '')).join('')}`);
  /*return `0x${ethers.utils.keccak256(`0x${[
    'ff',
    creatorAddress,
    saltHex,
    ethers.utils.keccak256(byteCode)
  ].map(x => x.replace(/0x/, ''))
  .join('')}`).slice(-40)}`.toLowerCase()*/
  //console.log(ethers.utils.keccak256(byteCode));
  return `0x${ethers.utils .keccak256(
      `0x${['ff', creatorAddress, saltHex, ethers.utils.keccak256(byteCode)]
        .map((x) => x.replace(/0x/, ''))
        .join('')}`,
    )
    .slice(-40)}`.toLowerCase()
}

function numberToUint256(value) {
  const hex = value.toString(16)
  return `0x${'0'.repeat(64-hex.length)}${hex}`
}

function saltToHex(salt) {
  return ethers.utils.id(salt.toString())
}

function encodeParam(dataType, data) {
  const abiCoder = ethers.utils.defaultAbiCoder;
  return abiCoder.encode([dataType], [data]);
}

describe("BatchTransfer", function () {
  let token;
  let owner;
  let addr1;
  let addr2;
  let addr3;
  let Wallet;

  beforeEach(async () => {
    [owner, addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();
    const Fabric = await ethers.getContractFactory("Fabric");
    fabric = await Fabric.deploy();
    await fabric.deployed();
    console.log("fabric address: "+fabric.address);
    Wallet = await ethers.getContractFactory("Wallet");

    const TZToken = await ethers.getContractFactory("TZToken");
    var totalSupply = ethers.BigNumber.from(100000000);
    totalSupply = totalSupply.mul(ethers.BigNumber.from(10).pow(18));
    token = await TZToken.deploy(totalSupply.toString());
    console.log("Token: " + token.address);
  })

  it("deposit collect", async function () {
    var salt = 1;
    var saltHex = saltToHex(salt);
    console.log(saltHex);
    console.log(numberToUint256(salt));
    saltHex = numberToUint256(salt);
    var byteCode = `${Wallet.bytecode}${encodeParam("address", token.address).slice(2)}`;
    console.log(`${encodeParam("address", token.address)}`);
    console.log(`${encodeParam("address", token.address).slice(2)}`);
    var addr1Deposit = buildCreate2Address(fabric.address, saltHex, byteCode);
    //var addr1Deposit = buildCreate2Address(fabric.address, ethers.utils.formatBytes32String(0x1), Wallet.bytecode);
    console.log("addr1Deposit: " + addr1Deposit);
    expect(await token.balanceOf(addr1Deposit)).to.be.equal(0);
    expect(await token.balanceOf("0xc631DBE5b364033BbA5195bB2a5f9A987b6a18a0")).to.be.equal(0);
    await token.connect(owner).transfer(addr1Deposit, 10000);
    expect(await token.balanceOf(addr1Deposit)).to.be.equal(10000);
    //await expect(fabric.createContract(saltToHex(salt))).to.emit(token, 'Transfer')
        //.withArgs(addr1Deposit, "0xc631DBE5b364033BbA5195bB2a5f9A987b6a18a0", 10000);
    const tx = await fabric.createContract(byteCode, saltHex);
    const receipt = await tx.wait();
    console.log(receipt.gasUsed);
    expect(await token.balanceOf(addr1Deposit)).to.be.equal(0);
    expect(await token.balanceOf("0xc631DBE5b364033BbA5195bB2a5f9A987b6a18a0")).to.be.equal(10000);
  })
});
