// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity =0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./Crowdsale.sol";
import "./AcidCrowdsale.sol";

contract AcidWhitelistCrowdsale is AcidCrowdsale {
    using SafeERC20 for IERC20;

    bytes32 public merkleRoot;

    constructor(
        uint hardCap_,
        bytes32 merkleRoot_,
        uint numerator_,
        uint denominator_,
        address wallet_,
        IERC20 token_,
        uint openingTime,
        uint closingTime
    ) AcidCrowdsale(hardCap_, numerator_, denominator_, wallet_, token_, openingTime, closingTime) {
        merkleRoot = merkleRoot_;
    }

    function setRoot(bytes32 merkleRoot_) external onlyOwner {
        merkleRoot = merkleRoot_;
    }

    function buyTokens(bytes32[] calldata merkleProof) external payable onlyWhileOpen nonReentrant {
        require(MerkleProof.verify(merkleProof, merkleRoot, keccak256(abi.encodePacked(msg.sender))), "AcidCrowdsale: invalid proof");
        _buyTokens();
    }
}
