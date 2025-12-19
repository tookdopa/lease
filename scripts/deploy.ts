import { ethers } from "hardhat";
import * as dotenv from "dotenv";
import * as fs from "fs";
import * as path from "path";

dotenv.config();

async function main() {
  const [deployer] = await ethers.getSigners();
  
  console.log("Deploying contracts...");
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "ETH");
  console.log("Deployer address:", deployer.address);
  
  const contracts: Record<string, string> = {};
    // Deploy CommercialLease
  const CommercialLeaseFactory = await ethers.getContractFactory("CommercialLease");
  const commercialLease = await CommercialLeaseFactory.deploy();
  await commercialLease.waitForDeployment();
  const commercialLeaseAddress = await commercialLease.getAddress();
  contracts["CommercialLease"] = commercialLeaseAddress;
  console.log("CommercialLease deployed to:", commercialLeaseAddress);
  // Summary
  console.log("\n" + "=".repeat(60));
  console.log("Deployment Summary");
  console.log("=".repeat(60));
  for (const [name, address] of Object.entries(contracts)) {
    console.log(name + ":", address);
  }
  console.log("=".repeat(60));
  
  // Save to contracts.json
  const contractsPath = path.join(__dirname, "..", "contracts.json");
  fs.writeFileSync(contractsPath, JSON.stringify(contracts, null, 2));
  console.log("\nContract addresses saved to contracts.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
