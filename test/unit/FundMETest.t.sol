// SPDX-License-dentifier:MIT

pragma solidity ^0.8.18;

import  {Test , console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol" ;

contract FundMETest is Test 
{
    FundMe fundMe ;

    address USER = makeAddr("user");            // falue user address
    uint256 constant SEND_VALUE = 0.1 ether ;
    uint256 constant STARTING_BALANCE = 10 ether ;
    uint256 constant GAS_PRICE = 1 ;

    function setUp() external 
    {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run() ;
        vm.deal(USER, STARTING_BALANCE); // false user's starting value 
    }

    function testMinimumDollarIsFive() public view
    {
        assertEq(fundMe.MINIMUM_USD() , 5e18);
    }

    function testOwnerIsMsgSender() public view
    {
        assertEq(fundMe.getOwner() , msg.sender);
    } 

    function testPriceFeedVersionIsAccurate() public view
    {
        uint256 version = fundMe.getVersion();
        assertEq(version , 4) ;    
    }

    function testFundFailsWithoutEnoughETH() public
    {
        vm.expectRevert(); // next line should revert
        fundMe.fund(); // send 0 value 
    }

    function testFundUpdatesFundedDataStructure() public
    {
        vm.prank(USER);                         // use false user
        fundMe.fund{value : SEND_VALUE} () ;    // false user create and send 
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded , SEND_VALUE);
    }

    function testAddsFunderTOArrayOfFunders() public
    {
        vm.prank(USER);
        fundMe.fund{value : SEND_VALUE} () ; // false user create and send 

        address funder = fundMe.getFunder(0);
        assertEq(funder , USER);
    }

    modifier funded()
    {
        vm.prank(USER);
        fundMe.fund{value : SEND_VALUE} () ; // false user create and send 
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded
    {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded
    {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance ;
        uint256 startingFundMeBalance = address(fundMe).balance ;

        // Act
        //uint256 gasStart = gasleft();

        //vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //uint256 gasEnd = gasleft();
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        //console.log(gasUsed) ;

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance ;
        uint256 endingFundMeBalance = address(fundMe).balance ;

        assertEq(endingOwnerBalance , startingOwnerBalance + startingFundMeBalance);
        assertEq(endingFundMeBalance , 0);
    }

    function testWithDrawFromMultipleFunders() public funded
    {
        // Arrange
        uint160 numberOfFunders = 10 ;
        uint160 statringFunderIndex = 1 ;

        for(uint160 i = statringFunderIndex ; i < numberOfFunders ; i++)
        {
            hoax(address(i) , SEND_VALUE);      // combine prank and deal with hoax   hoax only use uint160 to create
            fundMe.fund{value : SEND_VALUE} () ;
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance ;
        uint256 startingFundMeBalance = address(fundMe).balance ;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

         // Assert
        assert(address(fundMe).balance == 0);
        assert(fundMe.getOwner().balance == startingOwnerBalance + startingFundMeBalance);
    }


    function testWithDrawFromMultipleFundersCheaper() public funded
    {
        // Arrange
        uint160 numberOfFunders = 10 ;
        uint160 statringFunderIndex = 1 ;

        for(uint160 i = statringFunderIndex ; i < numberOfFunders ; i++)
        {
            hoax(address(i) , SEND_VALUE);      // combine prank and deal with hoax   hoax only use uint160 to create
            fundMe.fund{value : SEND_VALUE} () ;
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance ;
        uint256 startingFundMeBalance = address(fundMe).balance ;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

         // Assert
        assert(address(fundMe).balance == 0);
        assert(fundMe.getOwner().balance == startingOwnerBalance + startingFundMeBalance);
    }
}