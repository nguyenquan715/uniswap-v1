// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IExchange {
  function swapFromEthToToken(uint256 _minOutput) external payable;
  function swapFromEthToTokenWithRecipient(uint256 _minOutput, address _recipient) external payable;
  function swapFromTokenToEth(uint256 _tokenInputAmount, uint256 _minOutput) external;
}