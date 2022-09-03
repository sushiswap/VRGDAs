// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ShoyuLinearNFT} from "../ShoyuLinearNFT.sol";

/// @title Shoyu Linear VRGDA NFT Factory
/// @author z0r0z.eth <🍣>
/// @notice Factory for NFTs sold using LinearVRGDA for Shoyu.
contract ShoyuLinearNFTfactory {
    event CreateShoyuLinearNFT(
        address indexed nft, 
        string name, 
        string symbol, 
        string baseURI,
        int256 targetPrice,
        int256 priceDecayPercent,
        int256 perTimeUnit
    );

    function createShoyuLinearNFT(
        string memory _name, 
        string memory _symbol,
        string memory _baseURI,
        int256 _targetPrice,
        int256 _priceDecayPercent,
        int256 _perTimeUnit,
        bytes32 _salt
    ) external payable returns (address nft) {
        nft = address(new ShoyuLinearNFT{salt: _salt}(
                    _name,
                    _symbol,
                    _baseURI,
                    _targetPrice,
                    _priceDecayPercent,
                    _perTimeUnit
                )
        );
        
        emit CreateShoyuLinearNFT(
            nft, 
            _name, 
            _symbol, 
            _baseURI,
            _targetPrice,
            _priceDecayPercent,
            _perTimeUnit
        );
    }
}
