// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Constant product AMM
contract Uniswapper {
    uint256 public tokenNeoReserves = 100000 * 1e18;
    uint256 public tokenOneReserves = 5000 * 1e18;

    // @QUESTION -> Do I need to crete four events for each method called?
    event AmountTokenOneForExactTokenNeo(uint256 amount);
    event AmountExactTokenOneForTokenNeo(uint256 amount);
    event AmountTokenNeoExactTokenOne(uint256 amount);
    event AmountExactTokenNeoForTokenOne(uint256 amount);

    function getPriceOfTokenNeo() external view returns (uint256) {
        // @QUESTION: Why multiply again by 1e18?
        // why not multiply token Neo like token One?
        return (tokenOneReserves * 1e18) / tokenNeoReserves;
    }

    function getPriceOfTokenOne() external view returns (uint256) {
        return (tokenNeoReserves * 1e18) / tokenOneReserves;
    }

    // Buy a specific amount regardless the price
    // @QUESTION -> remix required to put payable - is that correct?
    function swapTokenOneForExactTokenNeo(
        uint256 _amountTokenNeo
    ) external payable {
        uint256 _tokenOneRequired = ((tokenNeoReserves * tokenOneReserves) /
            (tokenNeoReserves - _amountTokenNeo)) - tokenOneReserves;

        tokenNeoReserves -= _amountTokenNeo;
        tokenOneReserves += _tokenOneRequired;

        emit AmountTokenOneForExactTokenNeo(_tokenOneRequired);
    }

    // spend 1 token One for any amount of token Neo
    function swapExactTokenOneForTokenNeo(
        uint256 _amountTokenOne
    ) external payable {
        uint256 _tokenNeoRequired = ((tokenNeoReserves * tokenOneReserves) /
            (tokenOneReserves - _amountTokenOne)) - tokenNeoReserves;

        tokenNeoReserves += _tokenNeoRequired;
        tokenOneReserves -= _amountTokenOne;

        emit AmountExactTokenOneForTokenNeo(_amountTokenOne);
    }

    // sell as many token Neo for Token One
    function swapTokenNeoForExactTokenOne(
        uint256 _amountTokenOne
    ) external payable {
        uint256 _tokenNeoRequired = ((tokenNeoReserves * tokenOneReserves) /
            (tokenOneReserves + _amountTokenOne)) + tokenNeoReserves;

        tokenOneReserves -= _amountTokenOne;
        tokenNeoReserves += _tokenNeoRequired;

        emit AmountTokenNeoExactTokenOne(_amountTokenOne);
    }

    // sell token Neo as per demand regardless of price token One
    function swapExactTokenNeoForTokenOne(
        uint256 _amountTokenNeo
    ) external payable {
        uint256 tokenOneRequired = ((tokenNeoReserves * tokenOneReserves) /
            (tokenNeoReserves + _amountTokenNeo)) + tokenOneReserves;

        tokenOneReserves += tokenOneRequired;
        tokenNeoReserves -= _amountTokenNeo;

        emit AmountExactTokenNeoForTokenOne(_amountTokenNeo);
    }
}
