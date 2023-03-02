// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity =0.8.18;

import "./AcidCrowdsale.sol";

interface ICrowdsale {
    function subjectRaised() external view returns (uint);
}

contract AcidPublicCrowdsale is AcidCrowdsale {
    ICrowdsale public wlCrowdsale;

    constructor(
        uint hardCap_,
        ICrowdsale wlCrowdsale_,
        uint numerator_,
        uint denominator_,
        address wallet_,
        IERC20 token_,
        uint openingTime,
        uint closingTime
    ) AcidCrowdsale(hardCap_, numerator_, denominator_, wallet_, token_, openingTime, closingTime) {
        wlCrowdsale = wlCrowdsale_;
    }

    function getPurchasableAmount(uint amount) public override view returns (uint) {
        uint cap = hardCap - wlCrowdsale.subjectRaised();
        return (amount + subjectRaised) > cap ? (cap - subjectRaised) : amount;
    }

    function buyTokens() public payable virtual onlyWhileOpen nonReentrant {
        _buyTokens();
    }
}