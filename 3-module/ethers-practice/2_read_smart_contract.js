const { ethers } = require('ethers');

const INFURA_ID = '';
const provider = new ethers.providers.JsonRpcProvider(`https://mainnet.infura.io/v3/${INFURA_ID}`);

const ERC20_ABI = [
    "function name() view returns (string)",
    "function symbol() view returns (string)",
    "function totalSupply() view returns (uint256)",
    "function balanceOf(address) view returns (uint)",
];

const address = '';
const contract = new ethers.Contract(address, ERC20_ABI, provider);

const main = async () => {
    const name = await contract.name();
    const symbol = await contract.symbol();
    const totalSupply = await contract.totalSupply();

    console.log(`\nReading from ${address}\n`);
    console.log(`\Name: ${name}\n`);
    console.log(`\nSymbol: ${symbol}\n`);
    console.log(`\nTotal Supply: ${totalSupply}\n`);

    const balance = contract.balanceOf('');
    console.log(`Balance Returned: ${balance}\n`);
    console.log(`Balance Formatted: ${ethers.utils.formatEther(balance)}\n`);
};

main();