// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {toDaysWadUnsafe} from "../utils/SignedWadMath.sol";

import {LinearVRGDA} from "../LinearVRGDA.sol";

/// @title Shoyu Linear VRGDA NFT
/// @author transmissions11 <t11s@paradigm.xyz>
/// @author FrankieIsLost <frankie@paradigm.xyz>
/// @author z0r0z.eth <🍣>
/// @notice NFT sold using LinearVRGDA for Shoyu.
contract ShoyuLinearNFT is ERC721, LinearVRGDA {
    /*//////////////////////////////////////////////////////////////
                              SALES STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSold; // The total number of tokens sold so far.

    uint256 public startTime = block.timestamp; // When VRGDA sales begun.
    
    string public baseURI; // The base metadata for tokens.

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name, 
        string memory _symbol,
        string memory _baseURI,
        int256 _targetPrice,
        int256 _priceDecayPercent,
        int256 _perTimeUnit
    ) payable 
        ERC721(_name, _symbol)
        LinearVRGDA(
            _targetPrice, 
            _priceDecayPercent, 
            _perTimeUnit 
        )
    {
        baseURI = _baseURI;
    }

    /*//////////////////////////////////////////////////////////////
                              MINTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function mint() external payable returns (uint256 mintedId) {
        unchecked {
            // Note: By using toDaysWadUnsafe(block.timestamp - startTime) we are establishing that 1 "unit of time" is 1 day.
            uint256 price = getVRGDAPrice(toDaysWadUnsafe(block.timestamp - startTime), mintedId = totalSold++);

            require(msg.value >= price, "UNDERPAID"); // Don't allow underpaying.

            _mint(msg.sender, mintedId); // Mint the NFT using mintedId.

            // Note: We do this at the end to avoid creating a reentrancy vector.
            // Refund the user any ETH they spent over the current price of the NFT.
            // Unchecked is safe here because we validate msg.value >= price above.
            SafeTransferLib.safeTransferETH(msg.sender, msg.value - price);
        }
    }

    /*//////////////////////////////////////////////////////////////
                                URI LOGIC
    //////////////////////////////////////////////////////////////*/

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, _toString(tokenId)));
    }
    
    function _toString(uint256 value) internal pure virtual returns (string memory str) {
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 word for the trailing zeros padding, 1 word for the length,
            // and 3 words for a maximum of 78 digits. Total: 5 * 0x20 = 0xa0.
            let m := add(mload(0x40), 0xa0)
            // Update the free memory pointer to allocate.
            mstore(0x40, m)
            // Assign the `str` to the end.
            str := sub(m, 0x20)
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                str := sub(str, 1)
                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))
                // Keep dividing `temp` until zero.
                temp := div(temp, 10)
                // prettier-ignore
                if iszero(temp) { break }
            }

            let length := sub(end, str)
            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 0x20)
            // Store the length.
            mstore(str, length)
        }
    }
}
