// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./DeadMansSwitch.sol";

contract SwitchFactory {
    mapping(address => address[]) public ownerSwitches;
    event SwitchCreated(address indexed owner, address SwitchAddress);

    function createSwitch(uint256 _checkInInterval, uint256 _gracePeriod) external{
        DeadMansSwitch newSwitch= new DeadMansSwitch(_checkInInterval, _gracePeriod);  
        address switchAddress = address(newSwitch);
        ownerSwitches[msg.sender].push(switchAddress);
        emit SwitchCreated(msg.sender, switchAddress);
    }

    function getSwitchesByOwner(address owner) external view returns(address[] memory){
        return ownerSwitches[owner];
    }
}