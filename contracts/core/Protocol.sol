/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;

import "./State.sol";


contract bZxProtocol is State {

    function()
        external
        payable
    {
        if (gasleft() <= 2300) {
            return;
        }

        address target = logicTargets[msg.sig];
        require(target != address(0), "target not active");

        bytes memory data = msg.data;
        assembly {
            let result := delegatecall(gas, target, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    function setTargets(
        string[] memory sigsArr,
        address[] memory targetsArr)
        public
        onlyOwner
    {
        require(sigsArr.length == targetsArr.length, "count mismatch");

        for (uint256 i=0; i < sigsArr.length; i++) {
            logicTargets[bytes4(keccak256(abi.encodePacked(sigsArr[i])))] = targetsArr[i];
        }
    }

    function getTarget(
        string memory sig)
        public
        view
        returns (address)
    {
        return logicTargets[bytes4(keccak256(abi.encodePacked(sig)))];
    }
}