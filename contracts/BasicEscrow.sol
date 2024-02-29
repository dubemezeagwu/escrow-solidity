// SPDX-License-Identifier: MIT
pragma solidity >= 0.6.12 <0.9.0;

contract BasicEscrow {
  // storage state variables 
    address public depositor;
    address public beneficiary;
    address public arbiter;

    error Forbidden(); // custom error handler
    event Approved(uint); // event handler


    // assign the storage variables from the constructor as a payable function because ether will be transferred
    constructor (address _arbiter, address _beneficiary) payable {
        depositor = msg.sender;
        arbiter = _arbiter;
        beneficiary = _beneficiary;
    }


    // approve the transfer of funds if the arbiter calls this function (escrow: arbiter holds the decision)
    // if the arbiter is not the caller, the function reverts back with an error
    // if approved, funds is transferred to the beneficiary and an event is emitted
    function approve () external {
        if (msg.sender != arbiter) {
            revert Forbidden();
        }
        
        uint256 value = address(this).balance;
        beneficiary.call{value: value}("");
        emit Approved(value);
    }
}