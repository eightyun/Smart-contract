// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script , console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

// 用来对FundMe合约进行存款的脚本
contract FundFundMe is Script 
{
    uint256 constant SEND_VALUE = 0.01 ether ;

    function fundFundMe(address mostRecentlyDeployed) public
    {
        vm.startBroadcast();        // vm.startBroadcast() 用来启动广播交易 没有启动广播 链上收不到数据
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();   
        vm.stopBroadcast();
    } 
    
    function run() external 
    {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe" , block.chainid) ;
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed) ;
        vm.stopBroadcast();
    }
}

// 用来对FundMe合约进行取款的脚本
contract WithdrawFundMe is Script
{
    function withdrawFundMe(address mostRecentlyDeployed) public
    {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();   
        vm.stopBroadcast();
    } 
    
    function run() external 
    {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe" , block.chainid) ;
        vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed) ;
        vm.stopBroadcast();
    }
}

