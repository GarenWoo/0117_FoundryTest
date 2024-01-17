// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../src/NFTMarket.sol";
import "../src/ERC777TokenGTT.sol";
import "../src/ERC721Token.sol";

contract ERC721TokenTest is Test {
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address carol = makeAddr("carol");
    ERC777TokenGTT public tokenContract;
    ERC721Token public nftContract;
    NFTMarket public nftMarketContract;
    address public tokenAddr;
    address public nftAddr;
    address public marketAddr;

    function setUp() public {
        vm.startPrank(alice);
        tokenContract = new ERC777TokenGTT();
        tokenAddr = address(tokenContract);
        nftContract = new ERC721Token();
        nftAddr = address(nftContract);
        nftMarketContract = new NFTMarket(tokenAddr);
        marketAddr = address(nftMarketContract);
        tokenContract.transfer(bob, 10000 * 10 ** 18); // bob initial token balance == 10000 * 10 ** 18
        tokenContract.transfer(carol, 20000 * 10 ** 18); // carol initial token balance == 20000 * 10 ** 18
        vm.stopPrank();
    }

    function test_ERC721Token_NFTMint() public {
        vm.startPrank(alice);
        nftContract.mint(alice, "No.0");
        nftContract.mint(bob, "No.1");
        nftContract.mint(carol, "No.2");
        vm.stopPrank();
        assertEq(
            nftContract.ownerOf(0),
            alice,
            "expect the owner of #0 NFT is alice"
        );
        assertEq(
            nftContract.ownerOf(1),
            bob,
            "expect the owner of #1 NFT is bob"
        );
        assertEq(
            nftContract.ownerOf(2),
            carol,
            "expect the owner of #2 NFT is carol"
        );
    }

    function test_ERC721Token_NFTApprove() public {
        vm.startPrank(alice);
        nftContract.mint(alice, "No.0");
        nftContract.approve(marketAddr, 0);
        vm.stopPrank();
        assertEq(
            nftContract.getApproved(0),
            marketAddr,
            "expect NFTMarket contract address is approved by alice"
        );
    }
}
