import { ethers } from "hardhat";
import "dotenv/config";

console.log(process.env.POLYGON_RPC_URL);
console.log(process.env.WALLET_PRIVATE_KEY);
console.log(process.env.POLYGON_CHAIN_ID);

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const KaitoToken = await ethers.getContractFactory("KaitoToken");
  const kaitoToken = await KaitoToken.deploy("Kaito", "KID", 1000);
  console.log(`Contract deploying to: ${kaitoToken.transactionHash}`);
  await kaitoToken.deployed();
  console.log(`Contract deployed successfully: ${kaitoToken.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
