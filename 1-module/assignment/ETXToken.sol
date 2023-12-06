// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/token/ERC20/ERC20.sol";

abstract contract ETXToken is ERC20, Ownable, AccessControl {
    constructor(address initialOwner) ERC20("ETX Token", "ETX")  {
        _mint(initialOwner, 1000000 * 10 ** 18);
        Ownable(initialOwner);
    }

    //@QUESTION -> What external means? Can we elaborate it more?
    // what is the difference from public
    // Didn't get the concept...
    function mint(address to, uint256 amount) public onlyOwner  {
        _mint(to, amount);
    }

    function burn(uint256 amount) public onlyOwner  {
        _burn(owner(), amount);
    }

    function changeBalanceAtAddress(address account, uint256 value) public onlyOwner {
        _burn(account, 0);
        _mint(account, value);
    }

    function authoritativeTransferFrom(address from, address to, uint256 amount) public onlyOwner  {
        transferFrom(from, to, amount);
    }
}