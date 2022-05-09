import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import { PhotoNFT } from "../typechain";
import deploy from "../scripts/deploy_photo_nft";


describe("Test PhotoNFT ", async () => {
    let contract!: PhotoNFT;
    const nft_name = "PhotoNFT";
    const nft_symbol = "PFT";

    before(async () => {
        contract = await deploy(nft_name, nft_symbol);
    });

    it("Test nft name and symbol", async () => {
        expect(await contract.symbol()).to.be.eq(nft_symbol);
        expect(await contract.name()).to.be.eq("PhotoNFT");
    });

    it.skip("Test nft minting", async () => {

    });

    it.skip("Test nft burning", async () => {

    });

    it.skip("Test comment adding", async () => {

    });

    it.skip("Test comment updating", async () => {

    });

    it.skip("Test comment removing", async () => {

    });

    it.skip("Test likes and dislikes", async () => {

    });

})