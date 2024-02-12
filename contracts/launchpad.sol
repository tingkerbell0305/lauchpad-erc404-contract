// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./erc404.sol";
import "./IUniswapV3Factory.sol";

contract LaunchpadERC404 is Ownable {
    uint256 public deployFee = 10**17; // 0.1eth
    address public v3Factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address public v3Router = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address public wEth = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address public admin = 0xb650F9F93390CCaA4856D67fA24d0E6332a18D17;
    address public dev = 0xE3E7f26a22f5227cDaa643Bc9aE458b3114301D1;
    uint256 private devFee = 0; //100%

    constructor() Ownable(msg.sender) {}

    function setInfo(
        address v3Factory_,
        address v3Router_,
        address wEth_,
        uint256 deployFee_,
        address admin_
    ) public onlyOwner {
        v3Factory = v3Factory_;
        v3Router = v3Router_;
        wEth = wEth_;
        deployFee = deployFee_;
        admin = admin_;
    }

    function deployToken(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 totalSupply,
        string memory dataUri,
        uint24 fee,        
        string memory imageType_,
        uint256 imageCount_,
        string memory website_,
        string memory desc_
    ) public payable returns(address){

        require(msg.value >= deployFee, "insufficient service fee");
        uint256 adminFee = deployFee * (100 - devFee)/ 100;
        payable(admin).transfer(adminFee);
        payable(dev).transfer(msg.value - adminFee);

        ERC404Token newErc404 = new ERC404Token(
            msg.sender,
            name,
            symbol,
            decimals,
            totalSupply,
            imageType_,
            imageCount_,
            website_,
            desc_
        );
        newErc404.setDataURI(dataUri);
        newErc404.setWhitelist(msg.sender, true);

        address newPool = IUniswapV3Factory(v3Factory).createPool(
            address(newErc404),
            wEth,
            fee
        );
        newErc404.setWhitelist(newPool, true);
        newErc404.setWhitelist(v3Router, true);
        newErc404.transferOwnership(msg.sender);
        return address(newErc404);
    }

    receive() external payable {}

    fallback() external payable {}
}
