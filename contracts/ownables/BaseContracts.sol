// SPDX-License-Identifier: MIT
pragma solidity >= 0.6.12 <0.9.0;

// parent contract that extends members and functionalities
contract Ownable {
    address public owner;

    error Forbidden();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) {
            revert Forbidden();
        }
        _;
    }
}

contract Transferable is Ownable {

    function transfer(address _addr) external onlyOwner {
        owner = _addr;
    }
}