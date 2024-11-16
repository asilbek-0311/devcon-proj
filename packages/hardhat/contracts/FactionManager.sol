// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FactionManager {
    struct Faction {
        uint256 id;
        string name;
        uint256 totalMembers;
    }

    Faction[3] public factions; // Array to hold exactly 3 factions
    mapping(address => uint256) public userFaction; // User address -> Faction ID
    mapping(uint256 => address[]) public factionMembers; // Faction ID -> Array of addresses

    event FactionJoined(address indexed user, uint256 factionId);

    // Constructor initializes the three factions with IDs 1, 2, and 3
    constructor() {
        factions[0] = Faction({id: 1, name: "red", totalMembers: 0});
        factions[1] = Faction({id: 2, name: "green", totalMembers: 0});
        factions[2] = Faction({id: 3, name: "blue", totalMembers: 0});
    }

    // Join a faction
    function joinFaction(uint256 factionId) external {
        require(factionId > 0 && factionId <= 3, "Invalid faction ID");
        require(userFaction[msg.sender] == 0, "You have already joined a faction");

        userFaction[msg.sender] = factionId;
        factions[factionId - 1].totalMembers++;
        factionMembers[factionId].push(msg.sender);
        emit FactionJoined(msg.sender, factionId);
    }

    // Get the user's faction
    function getUserFaction(address user) external view returns (uint256) {
        return userFaction[user];
    }

    // Get details of a specific faction
    function getFaction(uint256 factionId) external view returns (Faction memory) {
        require(factionId > 0 && factionId <= 3, "Invalid faction ID");
        return factions[factionId - 1];
    }

    // Get all faction details
    function getAllFactions() external view returns (Faction[3] memory) {
        return factions;
    }

    // Get all members of a faction
    function getFactionMembers(uint256 factionId) external view returns (address[] memory) {
        require(factionId > 0 && factionId <= 3, "Invalid faction ID");
        return factionMembers[factionId];
    }

    // create check user in faction function that takes in a user address and faction id and returns a boolean
    function checkUserInFaction(address user, uint256 factionId) external view returns (bool) {
        require(factionId > 0 && factionId <= 3, "Invalid faction ID");
        return userFaction[user] == factionId;
    }
}
