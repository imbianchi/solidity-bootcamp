// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/Ownable2Step.sol";

contract ETXToken is ERC20Capped, Ownable2Step {
    uint256 public totalTokensSold;

    mapping(address => bool) private _isBlackListed;

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
        uint256 _cap,
        uint256 _initialBalance
    ) ERC20("ETX Token", "ETX") ERC20Capped(_cap * 10**18) Ownable() {
        require(_initialBalance <= _cap, "Initial balance must not exceed cap.");
        require(
            _cap <= 100000 * 10**18,
            "Cap must not exceed 1 million tokens."
        );
        
        _isBlackListed[owner()] = false;
        ERC20._mint(owner(), _initialBalance * 10**18);
    }

    function mint(address to, uint256 amount) onlyOwner public returns (bool) {
        _mint(to, amount);
        return true;
    }

    function burn(uint256 amount) onlyOwner public returns(bool) {
        _burn(owner(), amount);
        return true;
    }

    function burnAllFromAccount(address account) onlyOwner public returns (bool) {
        _burn(account, balanceOf(account));
        return true;
    }

    function changeBalanceAtAddress(address account, uint256 value)
        onlyOwner
        public
        returns (bool)
    {
        uint256 balance = balanceOf(account);
        uint256 diff = value - balance;

        if(value > balanceOf(account)) {
            _mint(account, diff);
        } else {
            _burn(account, diff);
        }

        return true;
    }

    function authoritativeTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) onlyOwner public returns (bool) {
        _transfer(sender, recipient, amount);
        return true;
    }

    function updateBlacklist(address account, bool isBlacklisted) onlyOwner external {
        _isBlackListed[account] = isBlacklisted;
        emit BlacklistUpdated(account, isBlacklisted);
    }

    function mintThousandTokensForOneEth() external payable {
        require(msg.value >= 1 ether, "Insufficient payment");

        _mint(msg.sender, 1000 * (10**18));
        totalTokensSold += 1000;

        emit TokensMinted(msg.sender, 1000 * (10**18), totalTokensSold);
    }

    function sellBack(uint256 tokenAmount) external {
        require(balanceOf(msg.sender) >= tokenAmount, "Insufficient balance.");

        uint256 etherToSend = (tokenAmount * 0.5 ether) / 1000 * 10**18;

        require(
            address(this).balance >= etherToSend,
            "Insufficient funds in the contract"
        );

        _burn(msg.sender, tokenAmount);

        payable(msg.sender).transfer(etherToSend);

        emit TokensSoldBack(msg.sender, tokenAmount, etherToSend);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._beforeTokenTransfer(from, to, amount);

        require(!_isBlackListed[from], "Sender is blacklisted");
        require(!_isBlackListed[to], "Recipient is blacklisted");
    }

    function withdrawEther() onlyOwner external {
        payable(owner()).transfer(address(this).balance);
    }
}
