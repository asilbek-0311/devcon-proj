// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FactionManager.sol";

contract VotingManager {
    struct Vote {
        uint256 targetFactionId;
        address voter;
    }

    struct VotingSession {
        uint256 votingId;
        uint256 factionId; // Faction initiating the vote
        bool isActive;
        uint256 startTime; // Timestamp when voting starts
        uint256 endTime;   // Timestamp when voting ends
        mapping(uint256 => uint256) votes; // Target faction ID -> Votes count
        Vote[] allVotes; // List of all votes
    }

    FactionManager factionManager;

    uint256 public votingCounter;
    mapping(uint256 => VotingSession) public votingSessions; // Voting ID -> Voting session

    event VotingSessionCreated(uint256 votingId, uint256 factionId);
    event VoteCast(uint256 votingId, uint256 targetFactionId, address voter);

    constructor(address _factionManager) {
        factionManager = FactionManager(_factionManager);
    }

    // Start a new voting session
    function createVotingSession(uint256 factionId, uint256 duration) external {
        require(factionManager.getFaction(factionId).totalMembers > 0, "Faction must exist");
        require(duration > 0, "Duration must be greater than 0");

        votingCounter++;
        VotingSession storage newSession = votingSessions[votingCounter];
        newSession.votingId = votingCounter;
        newSession.factionId = factionId;
        newSession.isActive = true;
        newSession.startTime = block.timestamp;
        newSession.endTime = block.timestamp + duration;

        emit VotingSessionCreated(votingCounter, factionId);
    }

    // Cast a vote
    function castVote(uint256 votingId, uint256 targetFactionId) external {
        VotingSession storage session = votingSessions[votingId];
        uint256 userFaction = factionManager.getUserFaction(msg.sender);
        
        require(session.isActive, "Voting session is not active");
        require(block.timestamp >= session.startTime, "Voting has not started yet");
        require(block.timestamp <= session.endTime, "Voting period has ended");
        require(userFaction != 0, "You must join a faction to vote");
        require(userFaction == session.factionId, "Only members of the initiating faction can vote");
        require(targetFactionId != session.factionId, "Cannot attack own faction");

        session.votes[targetFactionId]++;
        session.allVotes.push(Vote({targetFactionId: targetFactionId, voter: msg.sender}));

        emit VoteCast(votingId, targetFactionId, msg.sender);
    }

    // Get voting results
    function getResults(uint256 votingId) external view returns (uint256[] memory, uint256[] memory) {
        VotingSession storage session = votingSessions[votingId];
        uint256 factionCount = 3;
        uint256[] memory factionIds = new uint256[](factionCount);
        uint256[] memory voteCounts = new uint256[](factionCount);

        for (uint256 i = 0; i < factionCount; i++) {
            factionIds[i] = i;
            voteCounts[i] = session.votes[i];
        }
        return (factionIds, voteCounts);
    }
}
