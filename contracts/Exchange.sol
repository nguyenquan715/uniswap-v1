// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
  address public tokenAddress;

  constructor(address _token) ERC20("Uniswap", "UWP") {
    require(_token != address(0), 'Invalid token address');
    tokenAddress = _token;
  }

  function getReserve() public view returns(uint256) {
    return IERC20(tokenAddress).balanceOf(address(this));
  }

  function addLiquidity(uint256 _tokenAmount) public payable returns(uint256) {
    IERC20 token = IERC20(tokenAddress);
    if (getReserve() == 0) {
      // Initialize the liquidity
      token.transferFrom(msg.sender, address(this), _tokenAmount);

      uint256 liquidity = address(this).balance;
      _mint(msg.sender, liquidity);
      return liquidity;
    } else {
      // Add more liquidity
      uint256 tokenReserve = getReserve();
      uint256 ethReserve = address(this).balance - msg.value;
      uint256 minTokenAmount = (msg.value *  tokenReserve) / ethReserve;

      require (_tokenAmount >= minTokenAmount, "Not enough token");
      token.transferFrom(msg.sender, address(this), minTokenAmount);

      uint256 liquidity = (totalSupply() * msg.value) / ethReserve;
      _mint(msg.sender, liquidity);
      return liquidity;
    }
  }

  function getTokenOutputAmount(uint256 _ethInputAmount) public view returns(uint256) {
    require (_ethInputAmount > 0, 'Amount must be greater than 0');
    uint256 tokenReserve = getReserve();
    return _getOutputAmount(_ethInputAmount, address(this).balance, tokenReserve);
  }

  function getEthOutputAmount(uint256 _tokenInputAmount) public view returns(uint256) {
    require (_tokenInputAmount > 0, 'Amount must be greater than 0');
    uint256 tokenReserve = getReserve();
    return _getOutputAmount(_tokenInputAmount, tokenReserve, address(this).balance);
  }

  function swapFromEthToToken(uint256 _minOutput) public payable {
    uint256 tokenReserve = getReserve();
    uint256 tokenOutputAmount = _getOutputAmount(msg.value, address(this).balance - msg.value, tokenReserve);
    require (tokenOutputAmount >= _minOutput, 'Insufficient output amount');
    IERC20(tokenAddress).transferFrom(address(this), msg.sender, tokenOutputAmount);
  }

  function swapFromTokenToEth(uint256 _tokenInputAmount, uint256 _minOutput) public {
    uint256 tokenReserve = getReserve();
    uint256 ethOutputAmount = _getOutputAmount(_tokenInputAmount, tokenReserve, address(this).balance);
    require (ethOutputAmount >= _minOutput, 'Insufficient output amount');
    
    IERC20(tokenAddress).transferFrom(msg.sender, address(this), _tokenInputAmount);
    payable(msg.sender).transfer(ethOutputAmount);
  }

  function removeLiquidity(uint256 _lpAmount) public returns(uint256, uint256) {
    require (_lpAmount > 0, "Invalid LP token amount");

    uint256 ethAmount = (address(this).balance * _lpAmount) / totalSupply();
    uint256 tokenAmount = (getReserve() * _lpAmount) / totalSupply();

    _burn(msg.sender, _lpAmount);
    payable(msg.sender).transfer(ethAmount);
    IERC20(tokenAddress).transfer(msg.sender, tokenAmount);

    return (ethAmount, tokenAmount);
  }

  function _getOutputAmount(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) private pure returns(uint256) {
    require (inputReserve > 0 && outputReserve > 0, 'Not enough liquidity for this pair');
    uint256 inputAmountWithFee = inputAmount * 99;
    uint256 numerator = inputAmountWithFee * outputReserve;
    uint256 denominator = (inputReserve * 100) + inputAmountWithFee;
    return numerator / denominator;
  }
}