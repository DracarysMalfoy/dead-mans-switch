// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/DeadMansSwitch.sol";
import "../src/SwitchFactory.sol";

contract DeadMansSwitchTest is Test{
    DeadMansSwitch switch_;
    address owner;
    address beneficiary1;
    address beneficiary2;

    function setUp() public{
        owner=makeAddr("owner");
        beneficiary1=makeAddr("beneficiary 1");
        beneficiary2=makeAddr("beneficiary 2");

        vm.prank(owner);
        switch_=new DeadMansSwitch(3600, 1800);

        vm.prank(owner);
        switch_.addBeneficiary(beneficiary1, 60);

        vm.prank(owner);
        switch_.addBeneficiary(beneficiary2, 40);

        deal(owner, 10 ether);
    }

    function testCheckIn() public{
        vm.warp(block.timestamp + 3601);
        vm.prank(owner);
        switch_.checkIn();
        assertEq(switch_.lastCheckIn(), block.timestamp);
    }

    function testTriggerGracePeriod() public{
        vm.warp(block.timestamp + 3601);
        switch_.triggerGracePeriod();
        assertEq(uint256(switch_.status()), uint256(IDeadMansSwitch.Status.GracePeriod));
    }

    function testClaim() public{
        vm.prank(owner);
        switch_.deposit{value : 1 ether}(address(0), 1 ether);
        vm.warp(block.timestamp + 3601);
        switch_.triggerGracePeriod();
        vm.warp(block.timestamp + 1801);
        uint256 balanceBefore=beneficiary1.balance;
        vm.prank(beneficiary1);
        switch_.claim();
        uint256 balanceAfter=beneficiary1.balance;
        assertGt(balanceAfter, balanceBefore);
    }

    function testCancel() public{
        vm.prank(owner);
        switch_.deposit{value : 1 ether}(address(0), 1 ether);
        uint256 balanceBefore=owner.balance;
        vm.prank(owner);
        switch_.cancel();
        assertEq(uint256(switch_.status()), uint256(IDeadMansSwitch.Status.Cancelled));
        assertGt(owner.balance, balanceBefore);
    }

    function testCreateSwitch() public{
        SwitchFactory factory = new SwitchFactory();
        factory.createSwitch(3600, 1800);
        address[] memory switches = factory.getSwitchesByOwner(address(this));
        assertEq(switches.length, 1);
    }
}