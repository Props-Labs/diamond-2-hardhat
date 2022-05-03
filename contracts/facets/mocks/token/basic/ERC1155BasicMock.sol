// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @author: @props

import '@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol';

/**
 * @dev mock of a super basic ERC1155 contract used by other mocks
 */
contract ERC1155BasicMock is ERC1155Supply {

    constructor(string memory uri_) ERC1155(uri_) {}

    function mint(address _address, uint256 _id, uint256 _amount) external payable {
        _mint(_address, _id, _amount, "");
    }

}
