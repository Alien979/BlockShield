const ThreatDataContract = artifacts.require("ThreatDataContract");

module.exports = function(deployer) {
  deployer.deploy(ThreatDataContract);
};