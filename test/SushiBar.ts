import {expect} from "chai";
import hre from "hardhat";

const sushiContract="0x6B3595068778DD592e39A122f4f5a5cF09C90fE2";

describe("SushiBar contract",function(){
    it("Deployment",async function(){
        const SushiBar = await hre.ethers.getContractFactory("SushiBar");
        const sushibar = await SushiBar.deploy(sushiContract);
        expect(await sushibar.sushi()).to.equal(sushiContract);
    });
});