// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/token/ERC20/ERC20.sol";

contract ETXToken is ERC20, Ownable, AccessControl {
    mapping(address => bool) private _isBlacklisted;

    event BlacklistUpdated(address indexed account, bool isBlacklisted);

    constructor(
        address initialOwner,
        uint256 amount
    ) ERC20("ETX Token", "ETX") Ownable(initialOwner) {
        _mint(initialOwner, amount * 10 ** 18);
    }

    //@QUESTION -> What external means? Can we elaborate it more?
    // what is the difference from public
    // Didn't get the concept...
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

    function updateBlacklist(
        address account,
        bool isBlacklisted
    ) external onlyOwner {
        _isBlacklisted[account] = isBlacklisted;
        emit BlacklistUpdated(account, isBlacklisted);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        require(!_isBlacklisted[from], "Sender is blacklisted");
        require(!_isBlacklisted[to], "Recipient is blacklisted");

        return super.transferFrom(from, to, amount);
    }

    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        require(!_isBlacklisted[to], "Recipient is blacklisted");

        return super.transfer(to, amount);
    }
}
