import { ethers } from "hardhat";


async function deploy(name: string, symbol: string) {
    const factory = await ethers.getContractFactory("PhotoNFT");
    const contract = await factory.deploy(name, symbol);
    await contract.deployed();
    return contract;
}


async function main() {
    // await deploy();
    console.log("+++ Set name and symbol for NFT contract");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

export default deploy;