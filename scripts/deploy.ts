import hre from "hardhat";

async function main() {
  const sushiContract="0x6B3595068778DD592e39A122f4f5a5cF09C90fE2";


  const SushiBar = await hre.ethers.getContractFactory("SushiBar");
  const sushibar = await SushiBar.deploy(sushiContract);

  await sushibar.deployed();

  console.log("SushiBar deployed to:", sushibar.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
