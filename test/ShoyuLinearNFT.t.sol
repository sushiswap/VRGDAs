// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";

import {ShoyuLinearNFTfactory} from "../src/ShoyuLinearNFTfactory.sol";
import {ShoyuLinearNFT} from "../src/ShoyuLinearNFT.sol";

contract ShoyuLinearNFTTest is DSTestPlus {
    ShoyuLinearNFT nft;
    ShoyuLinearNFTfactory factory;

    string internal name = "Example Linear NFT";

    string internal symbol = "LINEAR";

    string internal baseURI = "PLACEHOLDER";

    int256 internal constant targetPrice = 69.42e18;

    int256 internal constant priceDecayPercent = 0.31e18;

    int256 internal constant perTimeUnit = 2e18;

    bytes32 internal constant salt = 0x73686f7975000000000000000000000000000000000000000000000000000000;

    function setUp() public {
        factory = new ShoyuLinearNFTfactory();

        nft = factory.createShoyuLinearNFT(
            address(this),
            name,
            symbol,
            baseURI,
            targetPrice,
            priceDecayPercent,
            perTimeUnit,
            salt
        );
    }

    function testMintNFT() public {
        nft.mint{value: 83.571859212140979125e18}();

        assertEq(nft.balanceOf(address(this)), 1);
        assertEq(nft.ownerOf(0), address(this));
    }

    function testCannotUnderpayForNFTMint() public {
        hevm.expectRevert("UNDERPAID");
        nft.mint{value: 83e18}();
    }

    function testMintManyNFT() public {
        for (uint256 i = 0; i < 100; i++) {
            nft.mint{value: address(this).balance}();
        }

        assertEq(nft.balanceOf(address(this)), 100);
        for (uint256 i = 0; i < 100; i++) {
            assertEq(nft.ownerOf(i), address(this));
        }
    }

    receive() external payable {}
}
