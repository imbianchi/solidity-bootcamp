const { ethers } = require('ethers');

const INFURA_ID = '';
const provider = new ethers.providers.JsonRpcProvider(`https://mainnet.infura.io/v3/${INFURA_ID}`);



const main = async () => {
    const latestBlock = await provider.getBlockNumber();
    console.log(`\nBlock Number: ${block}\n`);

    const blockInfo = await provider.getBlock(latestBlock);

    console.log(blockInfo);

    const { transactions } = await provider.getBlockWithTRansactions(latestBlock);
    console.log(transactions[0]);
};

main();