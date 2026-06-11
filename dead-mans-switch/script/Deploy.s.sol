// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/DeadMansSwitch.sol";
import "../src/SwitchFactory.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        DeadMansSwitch switch_ = new DeadMansSwitch(3600, 1800);
        SwitchFactory factory = new SwitchFactory();
        console.log("DeadMansSwitch:", address(switch_));
        console.log("SwitchFactory:", address(factory));
        vm.stopBroadcast();
    }
}