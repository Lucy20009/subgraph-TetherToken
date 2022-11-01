const TetherToken = artifacts.require('./TetherToken.sol')

module.exports = async function(deployer) {
    // TetherToken(uint _initialSupply, string _name, string _symbol, uint _decimals)
  await deployer.deploy(TetherToken,'1000000','testName','testSymbol','5')
}
