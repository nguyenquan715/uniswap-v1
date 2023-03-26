// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Exchange.sol";

contract Factory {
  mapping(address => address) public tokenToExchangePools;

  function createExchangePool(address _tokenAddress) public returns(address) {
    require(_tokenAddress != address(0), "Invalid token address");
    require (tokenToExchangePools[_tokenAddress] == address(0), "This pool has already existed");

    Exchange pool = new Exchange(_tokenAddress);
    tokenToExchangePools[_tokenAddress] = address(pool);

    return address(pool);
  }

  function getExchangePool(address _tokenAddress) public view returns(address) {
    return tokenToExchangePools[_tokenAddress];
  }
}