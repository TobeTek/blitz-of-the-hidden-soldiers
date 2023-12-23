
const { deployer } = await getNamedAccounts();
const simpleStorage = await ethers.getContract("SimpleStorage", deployer);