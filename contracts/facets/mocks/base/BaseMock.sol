// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @author: @props

import "../../base/Base.sol";
import "../Mock.sol";

/**
 * @dev 
 */
contract BaseMock is
    Base,
    Mock {

    constructor() Mock("BaseMock") {}

    /**
     * @dev see {IERC165-supportsInterface}
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(Base) returns (bool) {
    	return Base.supportsInterface(interfaceId);      // inherit interface support from Base
    }

}
