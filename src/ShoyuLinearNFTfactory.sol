// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ShoyuLinearNFT} from "./ShoyuLinearNFT.sol";

/// @title Shoyu Linear VRGDA NFT Factory
/// @author z0r0z.eth <🍣>
/// @notice Factory for NFTs sold using LinearVRGDA for Shoyu.
contract ShoyuLinearNFTfactory {
    event CreateShoyuLinearNFT(
        ShoyuLinearNFT indexed nft,
        address indexed owner,
        string name,
        string symbol,
        string baseURI,
        int256 targetPrice,
        int256 priceDecayPercent,
        int256 perTimeUnit
    );

    function createShoyuLinearNFT(
        address _owner,
        string calldata _name,
        string calldata _symbol,
        string calldata _baseURI,
        int256 _targetPrice,
        int256 _priceDecayPercent,
        int256 _perTimeUnit,
        bytes32 _salt
    ) external payable returns (ShoyuLinearNFT nft) {
        nft = new ShoyuLinearNFT{salt: _salt}(_owner, _name, _symbol, _baseURI, _targetPrice, _priceDecayPercent, _perTimeUnit);

        emit CreateShoyuLinearNFT(nft, _owner, _name, _symbol, _baseURI, _targetPrice, _priceDecayPercent, _perTimeUnit);
    }
}
