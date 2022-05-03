// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @author: @props

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

/**
 * @dev mock of a super basic ERC721 contract used by other mocks
 */
contract ERC721BasicMock is ERC721Enumerable {

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    function safeMint(address _address, uint256 _id) external payable {
        _safeMint(_address, _id, "");
    }

}
