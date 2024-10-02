// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract VotingSystem {
    struct Proposal {
        string name;
        uint256 voteCount;
    }

    address public owner;
    mapping(address => bool) public whitelist;
    Proposal[] public proposals;
    mapping(address => bool) public hasVoted;
    uint256 public startTime;
    uint256 public votingDuration = 3 days;

    event ProposalAdded(string name);
    event VoteCasted(address voter, uint256 index);

    constructor() {
        owner = msg.sender;
        startTime = block.timestamp;
    }

    // Modifiers to check the conditions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Only whitelisted addresses can perform this action.");
        _;
    }

    modifier votingPeriod() {
        require(block.timestamp <= startTime + votingDuration, "Voting period has ended.");
        _;
    }

    // Add a proposal to the list
    function addProposal(string memory name) public onlyOwner {
        proposals.push(Proposal(name, 0));
        emit ProposalAdded(name);
    }

    // Add an address to the whitelist to allow voting
    function addToWhitelist(address _address) public onlyOwner {
        whitelist[_address] = true;
    }

    // Check if an address can vote
    function isWhitelisted(address _address) public view returns (bool) {
        return whitelist[_address];
    }

    function vote(uint256 proposalIndex) public onlyWhitelisted votingPeriod {
        require(!hasVoted[msg.sender], "You have already voted.");
        require(proposalIndex < proposals.length, "Proposal does not exist.");

        proposals[proposalIndex].voteCount += 1;
        hasVoted[msg.sender] = true;

        emit VoteCasted(msg.sender, proposalIndex);
    }

    function getProposals() public view returns (Proposal[] memory) {
        return proposals;
    }
}
