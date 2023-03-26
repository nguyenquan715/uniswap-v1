// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IFactory {
  function getExchangePool(address _tokenAddress) external view returns(address);
}