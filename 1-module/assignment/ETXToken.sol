// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/AccessControl.sol";

contract ETXToken is ERC20Capped, Ownable, AccessControl {
    uint256 public totalTokensSold;
    mapping(address => bool) private _isBlacklisted;

    event BlacklistUpdated(address indexed account, bool isBlacklisted);
    event TokensMinted(
        address indexed buyer,
        uint256 amount,
        uint256 totalTokensSold
    );
    event TokensSoldBack(
        address indexed seller,
        uint256 amount,
        uint256 etherReceived
    );

    constructor(
        address initialOwner,
        uint256 cap,
        uint256 initialBalance
    ) ERC20("ETX Token", "ETX") Ownable() ERC20Capped(cap * 10 ** 18) {
        require(initialBalance <= cap, "Initial balance must not exceed cap.");
        owner();
        ERC20._mint(initialOwner, initialBalance * 10 ** 18);
    }

    /* ############### ERC20 with god-mode ################### */
    /* ####################################################### */

    function mint(address to, uint256 amount) public onlyOwner returns (bool) {
        _mint(to, amount);
        return true;
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(owner(), amount);
    }

    function burnAllFromAccount(
        address account
    ) public onlyOwner returns (bool) {
        _burn(account, balanceOf(account));
        return true;
    }

    function changeBalanceAtAddress(
        address account,
        uint256 value
    ) public onlyOwner returns (bool) {
        _burn(account, balanceOf(account));
        _mint(account, value);
        return true;
    }

    function authoritativeTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public onlyOwner returns (bool) {
        _transfer(sender, recipient, amount);

        return true;
    }

    /* ############### ERC20 with sanctions ################### */
    /* ####################################################### */

    function updateBlacklist(
        address account,
        bool isBlacklisted
    ) external onlyOwner {
        _isBlacklisted[account] = isBlacklisted;
        emit BlacklistUpdated(account, isBlacklisted);
    }

    /* ####################################################### */
    /* ################### Token Sale ######################## */

    function mintTokens() external payable {
        require(totalTokensSold + 1000 <= cap(), "Token sale has ended");
        require(msg.value >= 1 ether, "Insufficient payment");

        _mint(msg.sender, 1000 * (10 ** 18));
        totalTokensSold += 1000;

        emit TokensMinted(msg.sender, 1000 * (10 ** 18), totalTokensSold);
    }

    /* ################# Partial Refund ###################### */
    /* ####################################################### */

    function sellBack(uint256 tokenAmount) external {
        require(balanceOf(msg.sender) >= tokenAmount, "Insufficient balance");

        // Calculate the amount of Ether to send back based on the tokenAmount
        uint256 etherToSend = (tokenAmount * 0.5 ether) / 1000;

        // Check if the contract has enough Ether to pay the user
        require(
            address(this).balance >= etherToSend,
            "Insufficient funds in the contract"
        );

        // Burn the tokens from the seller's balance
        _burn(msg.sender, tokenAmount);

        // Transfer Ether to the seller
        payable(msg.sender).transfer(etherToSend);

        emit TokensSoldBack(msg.sender, tokenAmount, etherToSend);
    }

    /* ######################## overide ###################### */
    /* ####################################################### */

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._beforeTokenTransfer(from, to, amount);

        require(!_isBlacklisted[from], "Sender is blacklisted");
        require(!_isBlacklisted[to], "Recipient is blacklisted");
    }

    function withdrawEther() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
