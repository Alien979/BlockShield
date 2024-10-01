// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Reputation is Ownable {
    mapping(address => int256) private reputationScores;
    
    event ReputationUpdated(address user, int256 newScore);

    function updateReputation(address user, int256 change) external onlyOwner {
        reputationScores[user] += change;
        emit ReputationUpdated(user, reputationScores[user]);
    }

    function getReputation(address user) external view returns (int256) {
        return reputationScores[user];
    }
}