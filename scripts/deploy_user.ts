import { ethers } from "hardhat";


async function deploy() {
    const factory = await ethers.getContractFactory("User");
    const contract = await factory.deploy();
    await contract.deployed();
    return contract;
}


async function main() {
    const contract = await deploy();
    console.log("User contract deployed at:", contract.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

export default deploy;

