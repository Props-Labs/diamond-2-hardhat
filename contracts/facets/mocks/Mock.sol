// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @author: @props

/**
 * @dev simple contract we inherit into all mocks to help us test base contracts
 */
contract Mock {

    string public version_;

    constructor(string memory _version) {
        version_ = _version;
    }

    receive() external payable {}

    function version() external view returns (string memory) {
        return version_;
    }

}
