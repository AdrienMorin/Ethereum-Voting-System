// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract VotingSystem {
    struct Proposal {
        string name;
        uint256 voteCount;
    }

    address public owner;
    address[] public whitelist;
    Proposal[] public proposals;
    mapping(address => bool) public hasVoted;
    uint256 public startTime;
    uint256 public votingDuration = 3 days;

    event ProposalAdded(string name);
    event VoteCasted(address voter, string proposalName);

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
        require(isWhitelisted(msg.sender), "Only whitelisted addresses can perform this action.");
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

    // Add an adress to the white list to allow voting
    function addToWhitelist(address _address) public onlyOwner {
        whitelist.push(_address);
    }

    // Check if a member / adress can vote
    function isWhitelisted(address _address) public view returns (bool) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == _address) {
                return true;
            }
        }
        return false;
    }

    // Vote for a proposal by putting the name of the proposal
    function vote(string memory proposalName) public onlyWhitelisted votingPeriod {
        require(!hasVoted[msg.sender], "You have already voted.");

        uint256 proposalIndex = getProposalIndex(proposalName);
        require(proposalIndex != type(uint256).max, "Proposal does not exist.");

        proposals[proposalIndex].voteCount += 1;
        hasVoted[msg.sender] = true;

        emit VoteCasted(msg.sender, proposalName);
    }

    // Function to get a proposal index by putting in input the proposal name
    function getProposalIndex(string memory proposalName) public view returns (uint256) {
        for (uint256 i = 0; i < proposals.length; i++) {
            if (keccak256(abi.encodePacked((proposals[i].name))) == keccak256(abi.encodePacked((proposalName)))) {
                return i;
            }
        }
        return type(uint256).max;
    }

    function getProposals() public view returns (Proposal[] memory) {
        return proposals;
    }

    // Determine the top free proposals
    function getTopThreeProposals() public view returns (Proposal[] memory) {
        Proposal[] memory sortedProposals = new Proposal[](proposals.length);
        for (uint256 i = 0; i < proposals.length; i++) {
            sortedProposals[i] = proposals[i];
        }

        // Sorting the proposals
        for (uint256 i = 0; i < sortedProposals.length; i++) {
            for (uint256 j = i + 1; j < sortedProposals.length; j++) {
                if (sortedProposals[i].voteCount < sortedProposals[j].voteCount) {
                    Proposal memory temp = sortedProposals[i];
                    sortedProposals[i] = sortedProposals[j];
                    sortedProposals[j] = temp;
                }
            }
        }

        // Take the 3 first elements of the sorted list
        Proposal[] memory topThree = new Proposal[](3);
        for (uint256 i = 0; i < 3 && i < sortedProposals.length; i++) {
            topThree[i] = sortedProposals[i];
        }

        return topThree;
    }
}