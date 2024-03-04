// SPDX-License-Identifier: MIT

pragma solidity >= 0.6.12 <0.9.0;

contract VotingProposal {

  // proposal structure;
  // target: the address that the data will be sent to when the proposal will be executed
  // data: the data to be sent
  // yesCount: the amount of yes votes on the proposal
  // noCount: the amount of no votes on the proposal
  struct Proposal {
    address target;
    bytes data;
    uint yesCount;
    uint noCount;
  }

  enum Vote {
    NOT_CAST,
    YES, 
    NO
  }

  // events
  event ProposalCreated(uint proposalId);
  event VoteCasted(uint proposalId, address voter);

  Proposal[] public proposals;
  mapping (uint => mapping(address => Vote)) public votes;
  mapping (address => bool) public members;
  mapping (uint => bool) public executionCount;

  error Forbidden();

  // when the contract is deployed, an array of members is passed into the constructor
  // to make sure only members can perform actions
  constructor(address[] memory _members) {
    members[msg.sender] == true;
    for (uint i = 0; i < _members.length; i++) {
      members[_members[i]] = true;
    }
  }

  // modifier that helps verify only members have access before executing the forthcoming function
  modifier onlyMember(){
    if (!members[msg.sender]) {
      revert Forbidden();
    }
    _;
  }

  // create a new proposal and emit an event
  function newProposal (address _address, bytes calldata _calldata) external onlyMember {
    proposals.push(Proposal(_address, _calldata, 0, 0));
    emit ProposalCreated(proposals.length - 1);
  }

  // cast a vote
  // but before a vote is casted, we check to see if the address calling this function has voted before
  // if it has, we handle that by deleting their previous selection and allow them vote again
  function castVote (uint _id, bool _voteDecision) external onlyMember {
    if (hasVoted(_id, msg.sender)) {
      reduceVote(_id, votes[_id][msg.sender]);
    }

    if (_voteDecision) {
      proposals[_id].yesCount++;
      votes[_id][msg.sender] = Vote.YES;
    } else {
      proposals[_id].noCount++;
      votes[_id][msg.sender] = Vote.NO;
    }

    // if the yesCount on the proposal gets to a certain threshold, we execute the proposal 
    // & send the data to the target address
    if (proposals[_id].yesCount > 9 && !executionCount[_id]) {
      (bool success, ) = proposals[_id].target.call(proposals[_id].data);
      require(success);
      executionCount[_id] = true;
    }

    emit VoteCasted(_id, msg.sender);
  }

  // checks for if an address has casted a vote before
  function hasVoted(uint _id, address _addr) private view returns (bool) {
    return votes[_id][_addr] != Vote.NOT_CAST;
  }
  
  function reduceVote(uint _id, Vote _vote) private {
    if (_vote == Vote.YES) {
      proposals[_id].yesCount--;
    } else {
      proposals[_id].noCount--;
    }
  }
}