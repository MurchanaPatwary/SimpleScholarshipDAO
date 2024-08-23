// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleScholarshipDAO {
    struct Proposal {
        string description;
        address payable recipient;
        uint256 amount;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
    }

    Proposal[] public proposals;
    mapping(address => bool) public members;
    uint256 public totalMembers;

    event NewProposal(uint256 proposalId, string description, address recipient, uint256 amount);
    event Voted(uint256 proposalId, address voter, bool support);
    event ProposalExecuted(uint256 proposalId, bool successful);

    constructor() {
        members[msg.sender] = true; // The deployer is the first member
        totalMembers = 1;
    }

    modifier onlyMembers() {
        require(members[msg.sender], "Only DAO members can perform this action");
        _;
    }

    // Join the DAO as a member
    function joinDAO() external {
        require(!members[msg.sender], "Already a member");
        members[msg.sender] = true;
        totalMembers++;
    }

    // Propose a new scholarship
    function proposeScholarship(string memory _description, address payable _recipient, uint256 _amount) external onlyMembers {
        proposals.push(Proposal({
            description: _description,
            recipient: _recipient,
            amount: _amount,
            votesFor: 0,
            votesAgainst: 0,
            executed: false
        }));
        emit NewProposal(proposals.length - 1, _description, _recipient, _amount);
    }

    // Vote on a scholarship proposal
    function vote(uint256 _proposalId, bool _support) external onlyMembers {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");

        if (_support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        emit Voted(_proposalId, msg.sender, _support);
    }

    // Execute a proposal after voting
    function executeProposal(uint256 _proposalId) external onlyMembers {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.votesFor > proposal.votesAgainst, "Proposal did not pass");

        proposal.executed = true;
        proposal.recipient.transfer(proposal.amount);

        emit ProposalExecuted(_proposalId, true);
    }

    // Fund the DAO with Ether
    function fundDAO() external payable {}

    // Check DAO's balance
    function getDAOBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

