const GatekeeperOne = artifacts.require("GatekeeperOne");

module.exports = function (_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(GatekeeperOne);
};
