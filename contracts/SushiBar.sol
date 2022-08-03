// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./referenceContracts/IERC20.sol";
import "./referenceContracts/ERC20.sol";
import "./referenceContracts/SafeMath.sol";

// SushiBar is the coolest bar in town. You come in with some Sushi, and leave with more! The longer you stay, the more Sushi you get.
//
// This contract handles swapping to and from xSushi, SushiSwap's staking token.
contract SushiBar is ERC20("SushiBar", "xSUSHI"){
    using SafeMath for uint256;
    IERC20 public sushi;
    address public withdrawAddress;
    address rewardPoolAddress = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;
    uint256 public vestingStartTimestamp;
    uint256 public initialTokensBalance;
    // Define the Sushi token contract
    constructor(IERC20 _sushi) {
        sushi = _sushi;
    }


    // Enter the bar. Pay some SUSHIs. Earn some shares.
    // Locks Sushi and mints xSushi
    function enter(uint256 _amount) public {
        // Gets the amount of Sushi locked in the contract
        uint256 totalSushi = sushi.balanceOf(address(this));
        // Gets the amount of xSushi in existence
        uint256 totalShares = totalSupply();
        // If no xSushi exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalSushi == 0) {
            _mint(msg.sender, _amount);
        } 
        // Calculate and mint the amount of xSushi the Sushi is worth. The ratio will change overtime, as xSushi is burned/minted and Sushi deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount.mul(totalShares).div(totalSushi);
            _mint(msg.sender, what);
        }
        // Lock the Sushi in the contract
        sushi.transferFrom(msg.sender, address(this), _amount);
        vestingStartTimestamp = block.timestamp;
    }
    function canunstake() public  returns (uint256) {
        initialTokensBalance = sushi.balanceOf(address(this));
        uint256 canunstakevalue = 0;
        if ((block.timestamp-vestingStartTimestamp)>8 days){
            canunstakevalue =initialTokensBalance;
        }else if ((block.timestamp-vestingStartTimestamp)>6 days){
            canunstakevalue = (initialTokensBalance.mul(75)).div(100);
        }else if ((block.timestamp-vestingStartTimestamp)>4 days){
            canunstakevalue = (initialTokensBalance.mul(50)).div(100);
        }else if ((block.timestamp-vestingStartTimestamp)>2 days){
            canunstakevalue = (initialTokensBalance.mul(25)).div(100);
        }
        return canunstakevalue;       
    }

    // Leave the bar. Claim back your SUSHIs.
    // Unlocks the staked + gained Sushi and burns xSushi
    function leave(uint256 _share) public {
        // Gets the amount of xSushi in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of Sushi the xSushi is worth
        uint256 unstakingAmout = canunstake();
        uint256 tax = sushi.balanceOf(address(this)) - unstakingAmout;
        uint256 what = _share.mul(unstakingAmout).div(totalShares);
        _burn(msg.sender, _share);
        sushi.transfer(msg.sender, what);
        sushi.transfer(rewardPoolAddress,tax);
    }
}