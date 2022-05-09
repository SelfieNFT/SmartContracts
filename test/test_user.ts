import { ethers } from "hardhat";
import { expect } from "chai";
import deploy from "../scripts/deploy_user";
import { User } from "../typechain";


describe("Test User Contract", async () => {
    let user_contract!: User;

    beforeEach(async () => {
        user_contract = await deploy();
    });

    it("Test adding new user", async () => {
        const user_name = "temp user name";
        const [user1, user2] = await ethers.getSigners();

        await expect(
            user_contract.addUser("")
        ).to.be.revertedWith("Empty user name");

        let tx = await user_contract.addUser(user_name);
        await tx.wait();
        expect(await user_contract.userExists()).to.be.true;
        expect(await user_contract.userNames(user1.address)).to.be.eq(user_name);

        // add different name for the same user
        await expect(
            user_contract.addUser("different user name")
        ).to.be.revertedWith("User already exists");

        expect(await user_contract.connect(user2).userExists()).to.be.false;
        expect(await user_contract.userNames(user2.address)).to.be.eq("");

        // add the same user name like user1
        tx = await user_contract.connect(user2).addUser(user_name);
        await tx.wait();
        expect(await user_contract.connect(user2).userExists()).to.be.true;
        expect(await user_contract.userNames(user2.address)).to.be.eq(user_name);

    });

    it("Test changing user name", async () => {
        const user_name = "temp user name";
        const [user1] = await ethers.getSigners();

        await expect(
            user_contract.changeUserName("")
        ).to.be.revertedWith("Empty user name");

        await expect(
            user_contract.changeUserName(user_name)
        ).to.be.revertedWith("Add user first");

        let tx = await user_contract.addUser(user_name);
        await tx.wait();
        expect(await user_contract.userExists()).to.be.true;
        expect(await user_contract.userNames(user1.address)).to.be.eq(user_name);

        await expect(
            user_contract.changeUserName(user_name)
        ).to.be.revertedWith("New and old name are the same");

        tx = await user_contract.changeUserName("different user name");
        await tx.wait();
        expect(await user_contract.userNames(user1.address)).to.be.eq("different user name");
    });

    it("Test deleting user", async () => {
        const user_name = "Some user name";
        expect(await user_contract.userExists()).to.be.false;
        await expect(
            user_contract.deleteUser()
        ).to.be.revertedWith("User does not exist");

        let tx = await user_contract.addUser(user_name);
        await tx.wait();
        expect(await user_contract.userExists()).to.be.true;

        tx = await user_contract.deleteUser();
        await tx.wait();
        expect(await user_contract.userExists()).to.be.false;

        // add the same user again after deletion
        tx = await user_contract.addUser(user_name);
        await tx.wait();
        expect(await user_contract.userExists()).to.be.true;

    })
});