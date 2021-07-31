const Token = artifacts.require("PropertyListing");
const Manager = artifacts.require("PropertyManager");

module.exports = async function(deployer) {
	//deploy Token
	await deployer.deploy(Token)

	//assign token into variable to get it's address
	const token = await Token.deployed()
	
	//pass token address for Token contract(for future minting)
	await deployer.deploy(Manager, token.address)

	//assign Manager contract into variable to get it's address
	const Manager = await Manager.deployed()

	//change token's owner/minter from deployer to Manager
	await token.passMinterRole(Manager.address)
};