import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

export interface Signers {
  admin: SignerWithAddress;
  platform: SignerWithAddress;
  author: SignerWithAddress;
}
