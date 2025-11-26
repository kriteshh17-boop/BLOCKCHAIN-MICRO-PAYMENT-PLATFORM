// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    Project: Micro-Payment Platform
    Description: A simple contract that allows users to deposit funds,
                 pay per usage, and allows the owner to withdraw earnings.
*/

contract Project {
    address public owner;

    // User balances
    mapping(address => uint256) public balances;

    // Price per usage unit (in wei)
    uint256 public pricePerUnit;

    event Deposited(address indexed user, uint256 amount);
    event Charged(address indexed user, uint256 cost, uint256 units);
    event Withdrawn(address indexed owner, uint256 amount);

    constructor() {
        owner = msg.sender;
        pricePerUnit = 0.0001 ether; // default price
    }

    /// @notice Allows user to deposit ETH into their prepaid balance
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be > 0");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Deducts usage cost from user balance
    /// @param user The user being charged
    /// @param units How many units of service were consumed
    function chargeUser(address user, uint256 units) external onlyOwner {
        uint256 cost = units * pricePerUnit;
        require(balances[user] >= cost, "Insufficient balance");

        // Deduct funds and transfer to owner balance
        balances[user] -= cost;
        balances[owner] += cost;

        emit Charged(user, cost, units);
    }

    /// @notice Withdraws accumulated earnings for the owner
    function withdraw() external onlyOwner {
        uint256 amount = balances[owner];
        require(amount > 0, "No funds");

        balances[owner] = 0;

        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Withdraw failed");

        emit Withdrawn(owner, amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
}
