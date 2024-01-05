
const { deployer } = await getNamedAccounts();
const simpleStorage = await ethers.getContract("SimpleStorage", deployer);

// Mint standard pieces
// Mint Alexander the Great
// Mint Mansa