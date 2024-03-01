// SPDX-License-Identifier: MIT
pragma solidity >= 0.6.12 <0.9.0;

contract UserEscrow {
  struct User {
    uint balance;
    bool isActive;
  }

  // the usage of mappings here help for gas efficiency with the hashing of the addresses
  // we wouldn't have to perform iterations like we would in an array of users
  // with specific hash-key, we can obtain the value associated with that key 
  mapping (address => User) public users;

  error UserAlreadyCreated();
  error UserNotActive();
  error NotEnoughFunds();

  function createUser () external {
    if(users[msg.sender].isActive) {
      revert UserAlreadyCreated();
    }

    users[msg.sender] = User(100,true);
  }

  function transfer (address _recipient, uint _amount) external {
    if (!users[msg.sender].isActive || !users[_recipient].isActive) {
      revert UserNotActive();
    }

    if (users[msg.sender].balance < _amount) {
      revert NotEnoughFunds();
    }

    users[msg.sender].balance -= _amount;
    users[_recipient].balance += _amount;
  }
}