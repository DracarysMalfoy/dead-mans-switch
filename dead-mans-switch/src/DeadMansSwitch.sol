// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IDeadMansSwitch.sol";

contract DeadMansSwitch is IDeadMansSwitch, ReentrancyGuard {
    address public owner;
    uint256 public checkInInterval;
    uint256 public gracePeriod;   
    uint256 public lastCheckIn;
    IDeadMansSwitch.Status public status;
    struct Beneficiary{
        address wallet;
        uint256 sharePercent;
    }
    Beneficiary[] public beneficiaries;
    mapping(address => uint256) public tokenBalances;
    constructor(uint256 _checkInInterval, uint256 _gracePeriod){
        owner=msg.sender;
        checkInInterval=_checkInInterval;
        gracePeriod=_gracePeriod;
        lastCheckIn=block.timestamp;
        status=IDeadMansSwitch.Status.Active;
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }
    modifier onlyWhenActive(){
        require(
            status == IDeadMansSwitch.Status.Active ||
            status == IDeadMansSwitch.Status.GracePeriod,
            "Switch not active"
        );
        _;
    }
    function deposit(address token, uint256 amount) external payable onlyOwner{
        if(token==address(0)){
            require(msg.value == amount, "Wrong ETH amount");
            tokenBalances[address(0)]+=amount;
        }else{
            bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
            require(success, "Token transfer failed");
            tokenBalances[token]+=amount;
        }
    }
    function checkIn() external onlyOwner onlyWhenActive{
        lastCheckIn=block.timestamp;
        if(status == IDeadMansSwitch.Status.GracePeriod){
            status = IDeadMansSwitch.Status.Active;
        }
        emit CheckedIn(msg.sender, block.timestamp);
    }
    function addBeneficiary(address wallet, uint256 share) external onlyOwner{
        require(wallet!=address(0), "Invalid address");
        require(share>0, "Share must be greater than 0");
        beneficiaries.push(Beneficiary(wallet, share));
    }
    function removeBeneficiary(address wallet) external onlyOwner{
        for(uint256 i=0; i<beneficiaries.length; i++){
            if(beneficiaries[i].wallet==wallet){
            beneficiaries[i]=beneficiaries[beneficiaries.length-1];
            beneficiaries.pop();
            return;
            }
        }
        revert("Beneficiary not found");
    }
    function triggerGracePeriod() external{
        require(status==IDeadMansSwitch.Status.Active, "Not active");
        require(block.timestamp>lastCheckIn+checkInInterval, "Too early");
        status=IDeadMansSwitch.Status.GracePeriod;
        uint256 deadline=lastCheckIn+checkInInterval+gracePeriod;
        emit GracePeriodStarted(deadline);
    }
    function claim() external nonReentrant{
        require(status==IDeadMansSwitch.Status.GracePeriod, "Not in Grace Period");
        require(block.timestamp > lastCheckIn + checkInInterval + gracePeriod, "Too early");
        status=IDeadMansSwitch.Status.Triggered;
        emit SwitchTriggered(block.timestamp);
        for(uint256 i=0; i<beneficiaries.length; i++){
            uint256 ethAmount= tokenBalances[address(0)] * beneficiaries[i].sharePercent/100;
            (bool success, ) = beneficiaries[i].wallet.call{value: ethAmount}("");
            require(success, "ETH transfer failed");
            emit BeneficiaryClaimed(beneficiaries[i].wallet, ethAmount);
        }
    }
    function cancel() external onlyOwner onlyWhenActive{
        status=IDeadMansSwitch.Status.Cancelled;
        uint256 ethBalance=tokenBalances[address(0)];
        tokenBalances[address(0)]=0;
        (bool success, )=owner.call{value: ethBalance}("");
        require(success, "ETH Transfer failed");
        emit Cancelled(owner);
    }
}
