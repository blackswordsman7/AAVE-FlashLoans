var FlashLoanLiquidator = artifacts.require("./FlashLoanLiquidator.sol");

module.exports = function(deployer) {
 
  deployer.deploy(FlashLoanLiquidator, '0x9C6C63aA0cD4557d7aE6D9306C06C093A2e35408');
};
