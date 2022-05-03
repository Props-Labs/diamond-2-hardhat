// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @author: @props

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./base/Base.sol";
import "./base/IAdmin.sol";

contract Stakester is
    Base,
    ERC721,
    ERC721Pausable {

    // contract doesn't support IAdmin interface
    error InvalidAdminContract();
    // invalid category was specified
    error InvalidCategory();
    // one or more fusion parameters was not met
    error InvalidFusion();

    // emitted upon a successful fusion
    event Fused(Fusion[]);
    // emitted upon a successful mint
    event Minted(address, uint256);

    enum Category {
        All,
        Fused,
        Genesis,
        Legendary
    }

    struct Fusion {
        uint256 id;
        bytes32 attributeHash;
        bytes32[] proof;
    }

    address public adminContract;
    string private baseURI_;
    uint256[] public tokens;

    // how many tokens an address has minted
    mapping(address => uint256) public minted;
    mapping(address => mapping(uint256 => uint256)) public mintedByAllowlist;
    // categories by token id
    mapping(uint256 => Category) private _category;
    // merkle roots by category
    mapping(Category => bytes32) private _merkleRoots;

    constructor (
        string memory baseURI,
        address _adminContract
    ) ERC721("Stakester", "STAKESTER") {
        if (!IAdmin(_adminContract).supportsInterface(type(IAdmin).interfaceId)) revert InvalidAdminContract();
        baseURI_ = baseURI;
        adminContract = _adminContract;
        // seed tokens with zero index because token ids are not zero based
        tokens.push(0);
    }

    /**
     * @dev see {IERC165-supportsInterface}
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(Base, ERC721) returns (bool) {
        return interfaceId == type(IERC721).interfaceId || super.supportsInterface(interfaceId);
    }

    function mint(uint256 _quantity, bytes32[][] memory _proofs) external payable nonReentrant {
        // are the mint parameters met?
        IAdmin(adminContract).revertOnMintCheckFailure(0, _quantity, (tokens.length - 1), paused());
        // is caller allowed to mint _quantity?
        IAdmin.Allocation memory allocated = IAdmin(adminContract).getAllocationByAddress(msg.sender, _proofs);
        if ((_quantity + mintedByAllowlist[address(msg.sender)][allocated.allowlistId]) > allocated.allocation) revert IAdmin.AllocationExceeded();
        // is caller sending the correct amount of funds?
        if (allocated.price > 0) {
            // we're overriding mintConfig.price
            IAdmin(adminContract).revertOnPaymentFailure(0, allocated.price, _quantity, msg.value, true);
        } else {
            IAdmin(adminContract).revertOnPaymentFailure(0, 0, _quantity, msg.value, false);
        }
        // send funds to split contract
        Address.sendValue(IAdmin(adminContract).getSplitContract(), msg.value);
        // mint _quantity tokens
        unchecked {
            for (uint i = 0; i < _quantity; i ++) {
                _safeMint(msg.sender, tokens.length, "");
                tokens.push(tokens.length);
                // is the token that was just minted legendary? if so, add sender to royalty contract
                if (_category[tokens.length - 1] == Category.Legendary) _addRoyaltyShare(msg.sender);
                minted[address(msg.sender)]++;
                mintedByAllowlist[address(msg.sender)][allocated.allowlistId]++;
            }
        }
        emit Minted(msg.sender, _quantity);
    }

    /**
     * @dev fuse VIP tokens into a legendary token
     */
    function fuse(Fusion[] memory _tokensToFuse) external payable nonReentrant {
        // caller did not provide the proper number of token ids to fuse
        if (_tokensToFuse.length != 4) revert InvalidFusion();

        unchecked {
            // attributeHash for all tokens must be the same
            bytes32 _attributeHash = _tokensToFuse[0].attributeHash;
            for (uint i = 1; i < _tokensToFuse.length; i++) {
                if (_tokensToFuse[i].attributeHash != _attributeHash) revert InvalidFusion();
            }

            // check the caller's wallet to verify that they hold each of the appropriate tokens
            // it is expected that the first 3 tokens are the tokens being fused into the 4th token
            uint256 held = 0;
            for (uint i = 0; i < 3; i++) {
                if (msg.sender == ownerOf(_tokensToFuse[i].id)) held++;
            }
            if (held != 3) revert InvalidFusion();

            // verify that all of the token attributes match what's in the list of tokens
            for (uint i = 0; i < _tokensToFuse.length; i++) {
                if (!MerkleProof.verify(_tokensToFuse[i].proof, _merkleRoots[Category.All], keccak256(abi.encodePacked(_tokensToFuse[i].id, _tokensToFuse[i].attributeHash)))) revert InvalidFusion();
            }
        }

        // mint the fused token _before_ we burn the tokens we're fusing
        _safeMint(msg.sender, _tokensToFuse[3].id, "");
        tokens.push(_tokensToFuse[3].id);
        _category[_tokensToFuse[3].id] = Category.Fused;

        // burn the tokens that were just fused
        unchecked {
            for (uint i = 0; i < 3; i++) {
                _burn(_tokensToFuse[i].id);
            }
        }

        // add share to royalty contract for sender
        _addRoyaltyShare(msg.sender);
        emit Fused(_tokensToFuse);
    }

    /**
     * @dev sets admin contract address
     */
    function setAdminContract(address _address) external onlyRole(CONTRACT_ADMIN_ROLE) {
        if (!IAdmin(_address).supportsInterface(type(IAdmin).interfaceId)) revert InvalidAdminContract();
        adminContract = _address;
    }

    /**
     * @dev see {IERC721Metadata}
     */
    function setBaseURI(string memory baseURI) external onlyRole(CONTRACT_ADMIN_ROLE) {
        baseURI_ = baseURI;
    }

    /**
    * @dev set token category to enable royalty share management
    */
    function setCategory(Category category_, uint16[] memory _tokenIds) external onlyRole(CONTRACT_ADMIN_ROLE) {
        unchecked {
            for (uint i = 0; i < _tokenIds.length; i++) {
                if (category_ == Category.Genesis || category_ == Category.Legendary) {
                    _category[_tokenIds[i]] = category_;
                } else {
                    revert InvalidCategory(); 
                }
            }
        }
    }

    /**
    * @dev see {IAdmin-getContractURI}
    */
    function contractURI() external view returns (string memory) {
        return IAdmin(adminContract).getContractURI();
    }

    /**
    * @dev sets category merkle roots
    */
    function setMerkleRoot(Category category_, bytes32 _root) external onlyRole(CONTRACT_ADMIN_ROLE) {
        _merkleRoots[category_] = _root;
    }

    /**
    * @dev pauses the contract
    */
    function pause() external onlyRole(CONTRACT_ADMIN_ROLE) {
        _pause();
    }

    /**
    * @dev unpauses the contract
    */
    function unpause() external onlyRole(CONTRACT_ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @dev overrides {ERC721-_baseURI}
     */
    function _baseURI() internal view virtual override(ERC721) returns (string memory) {
        return baseURI_;
    }

    /**
    * @dev see {IRoyalty-addRoyaltyShare}
    */
    function _addRoyaltyShare(address _address) internal {
        IAdmin(adminContract).addRoyaltyShare(_address);
    }

    /**
    * @dev see {IRoyalty-removeRoyaltyShare}
    */
    function _removeRoyaltyShare(address _address) internal {
        IAdmin(adminContract).removeRoyaltyShare(_address);
    }

    /**
    * @dev overrides {ERC721-_beforeTokenTransfer}
    */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Pausable) {
        if (_category[tokenId] == Category.Fused || _category[tokenId] == Category.Legendary) {
            if (address(from) != address(0) && address(to) != address(0)) {
                // ignore if token is being minted or burned
                // remove royalty share from _from_ and add share for _to_
                _removeRoyaltyShare(from);
                _addRoyaltyShare(to);
            } else if (address(to) == address(0)) {
                // remove royalty share if royalty eligible token is being burned
                _removeRoyaltyShare(from);
            }
        }
        super._beforeTokenTransfer(from, to, tokenId);
    }

}
