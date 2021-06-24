const Hacker = artifacts.require("Hacker");
const GatekeeperOne = artifacts.require("GatekeeperOne");
const { expect } = require("chai");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Hacker", function ([_owner, _hacker]) {
  it("should pass three gatekeepers", async function () {
    const hackerContract = await Hacker.deployed();
    const targetContract = await GatekeeperOne.deployed();
    const result = await hackerContract.attack(targetContract.address, { from: _hacker });
    expect(result.receipt.status).to.be.equal(true);
    expect(await targetContract.entrant()).to.be.equal(_hacker);
  });
});
