const Assignment_3ABC = artifacts.require("Assignment_3ABC");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Assignment_3ABC);
};
