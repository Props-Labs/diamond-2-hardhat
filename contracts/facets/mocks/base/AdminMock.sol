// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @author: @props

import "../../base/Admin.sol";
import "../Mock.sol";

/**
 * @dev 
 */
contract AdminMock is
    Admin,
    Mock {

    constructor() Mock("AdminMock") {}

    /**
     * @dev see {IERC165-supportsInterface}
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(Admin) returns (bool) {
    	return Base.supportsInterface(interfaceId);      // inherit interface support from Base
    }

}
