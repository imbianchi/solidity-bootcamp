const { ethers } = require('ethers');

const INFURA_ID = '';
const provider = new ethers.providers.JsonRpcProvider(`https://mainnet.infura.io/v3/${INFURA_ID}`);

const account1 = ''; // sender
const account2 = ''; // recipient

const privateKey1 = '';
const wallet = ethers.Wallet(privateKey1, provider);

const main = async () => {
    // Show account 1 balance before transfer
    const senderBalanceBefore = await provider.getBalance(account1);
    // Show account 2 balance before transfer
    const recipientBalanceBefore = await provider.getBalance(account2);

    console.log(`\nSender balance before: ${ethers.utils.formatEther(senderBalanceBefore)}`);
    console.log(`\nRecipient balance before: ${ethers.utils.formatEther(recipientBalanceBefore)}`);

    // Send Ether
    const tx = await wallet.sendTransaction({
        to: account2,
        value: ethers.utils.parseEther("0.025")
    });

    // Wait for Transaction to be mined
    await tx.wait();
    console.log(tx);

    // Show account 1 balance after transfer
    const senderBalanceAfter = await provider.getBalance(account1);
    // Show account 2 balance after transfer
    const recipientBalanceAfter = await provider.getBalance(account2);

    console.log(`\nSender balance after: ${ethers.utils.formatEther(senderBalanceAfter)}`);
    console.log(`\nRecipient balance after: ${ethers.utils.formatEther(recipientBalanceAfter)}`);
};

main();