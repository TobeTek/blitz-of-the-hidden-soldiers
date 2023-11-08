// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

abstract contract HasOwner {
    address public _owner;
    bool public isActive;

    constructor() {}

    function selfDestruct(address payable recipient) external {
        require(
            msg.sender == _owner,
            "Must be owner of smart contract to call self destruct method"
        );

        // selfdestruct has been deprecated with Solidity 0.8.18
        // We simply send the balance on the smart contract to a recipient account
        // and mark it as unusable/inactive
        (bool success,) = recipient.call{value: address(this).balance}("");
        if (!success) {
            revert("call{value} failed");
        }
    }
}
