// SPDX-License-dentifier:MIT

pragma solidity ^0.8.18;

import  {Test , console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol" ;
import {FundFundMe , WithdrawFundMe} from "../../script/Interactions.s.sol" ;

//用来测试存取款的脚本的测试
contract IntegrationsTest is Test 
{
    FundMe fundMe ;

    address USER = makeAddr("user");            // falue user address
    uint256 constant SEND_VALUE = 0.1 ether ;
    uint256 constant STARTING_BALANCE = 10 ether ;
    uint256 constant GAS_PRICE = 1 ;

    function setUp() external 
    {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run() ;
        vm.deal(USER, STARTING_BALANCE); // false user's starting value 
    }   

    function testUserCanFundInteractions() public
    {
        FundFundMe fundFundMe = new FundFundMe() ;
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe() ;
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}