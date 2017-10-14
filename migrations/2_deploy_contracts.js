var ERC20 = artifacts.require("../contracts/ERC20.sol");
var TicketToken = artifacts.require("../contracts/TicketToken.sol");

module.exports = function(deployer) {
  //deployer.deploy(ERC20);
  deployer.deploy(TicketToken);
  
};
