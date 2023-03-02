// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity =0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Crowdsale.sol";
import "./TimedCrowdsale.sol";

abstract contract AcidCrowdsale is Crowdsale, TimedCrowdsale {
    using SafeERC20 for IERC20;

    uint public hardCap;

    constructor(
        uint hardCap_,
        uint numerator_,
        uint denominator_,
        address wallet_,
        IERC20 token_,
        uint openingTime,
        uint closingTime
    ) Crowdsale(numerator_, denominator_, wallet_, token_) TimedCrowdsale(openingTime, closingTime) {
        hardCap = hardCap_;
    }

    receive() external payable {
        revert();
    }

    function setCap(uint hardCap_) external onlyOwner {
        hardCap = hardCap_;
    }

    function getPurchasableAmount(uint amount) public virtual view returns (uint) {
        return (amount + subjectRaised) > hardCap ? (hardCap - subjectRaised) : amount;
    }

    function _buyTokens() internal {
        uint amount = getPurchasableAmount(msg.value);
        require(amount > 0, "AcidCrowdsale: purchasable amount is 0");

        if (amount < msg.value) {
            _safeTransferETH(msg.sender, msg.value - amount);
        }

        _safeTransferETH(wallet, amount);

        // update state
        subjectRaised += amount;
        purchasedAddresses[msg.sender] += amount;

        emit TokenPurchased(msg.sender, amount);
    }

    function claim() external nonReentrant {
        require(hasClosed(), "AcidCrowdsale: not closed");
        require(!claimed[msg.sender], "AcidCrowdsale: already claimed");

        uint tokenAmount = getTokenAmount(purchasedAddresses[msg.sender]);
        require(tokenAmount > 0, "AcidCrowdsale: not purchased");

        require(address(token) != address(0), "AcidCrowdsale: token not set");
        token.safeTransferFrom(wallet, msg.sender, tokenAmount);
        claimed[msg.sender] = true;

        emit TokenClaimed(msg.sender, tokenAmount);
    }
}
