// SPDX-License-Identifier: MIT

pragma solidity >= 0.6.12 <0.9.0;

contract SampleVoting {
  enum Choices {
    Yes,
    No
  }

  struct Vote {
    address voter;
    Choices choice;
  }

  Vote[] public votes;

  // null vote, if there is a vote matching the enteries in array of votes
  Vote internal NULL_VOTE = Vote(address(0), Choices(0));

  error VoteAlreadyCasted();
  error VoteNotFound();

  function createVote (Choices choice) external {
    if (hasVoted(msg.sender)){
      revert VoteAlreadyCasted();
    }
    votes.push(Vote(msg.sender, choice));
  }


  function changeVote(Choices _choice) external {
        Vote storage vote = findVote(msg.sender);
        if (vote.voter != msg.sender) {
            revert VoteNotFound();
        }

        vote.choice = _choice;
    }


  function findChoice (address _address) external view returns (Choices) {
    Vote storage vote = findVote(_address);
    if (_address == vote.voter) {
      return vote.choice;
    }

    // undefined case
    return Choices.No;
  }


  function hasVoted (address _address) public view returns (bool){
    Vote storage vote = findVote(_address);
    if (_address == vote.voter){
      return true;
    }

    return false;
  }


  function findVote (address _address) internal view returns (Vote storage) {
    for (uint i = 0; i < votes.length; i ++){
      if (_address == votes[i].voter) {
        return votes[i];
      }
    }
    return NULL_VOTE;
  }

}