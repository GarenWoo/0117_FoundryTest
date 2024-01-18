// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../src/NFTMarket.sol";
import "../src/ERC777TokenGTT.sol";
import "../src/ERC721Token.sol";

contract ERC777TokenGTTTest is Test {
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

    function test_ERC777TokenGTT_Owner() public {
        assertEq(
            tokenContract.owner(),
            alice,
            "expect tokenContract owner is alice"
        );
    }

    function test_ERC777TokenGTT_TransferAndBalance() public {
        vm.prank(alice);
        tokenContract.transfer(carol, 15000 * 10 ** 18);
        assertEq(
            tokenContract.balanceOf(alice),
            55000 * 10 ** 18,
            "expect the balance of alice is 55000 * 10 ** 18"
        );
        assertEq(
            tokenContract.balanceOf(bob),
            10000 * 10 ** 18,
            "expect the balance of alice is 10000 * 10 ** 18"
        );
        assertEq(
            tokenContract.balanceOf(carol),
            35000 * 10 ** 18,
            "expect the balance of alice is 35000 * 10 ** 18"
        );
    }

    function test_ERC777TokenGTT_transferWithCallbackForNFT() public {
        vm.startPrank(alice);
        nftContract.mint(alice, "No.0");
        nftContract.mint(bob, "No.1");
        tokenContract.approve(marketAddr, 10000 * 10 ** 18);
        vm.startPrank(bob);
        nftContract.approve(marketAddr, 1);
        nftMarketContract.list(nftAddr, 1, 100 * 10 ** 18);
        vm.stopPrank();
        bytes memory _data = abi.encode(nftAddr, 1);
        console.log("NFTMarket_tokensReceived=>transferWithCallbackForNFT@ERC777TokenGTT|marketAddr: ", marketAddr);
        console.logBytes(_data);
        vm.prank(alice);
        bool success = tokenContract.transferWithCallbackForNFT(
            marketAddr,
            101 * 10 ** 18,
            _data
        );
        assertEq(
            nftContract.ownerOf(1),
            alice,
            "expect the current owner of #1 NFT is alice after transferring token to NFTMarket"
        );
        assertTrue(success, "expect transferWithCallbackForNFT is successfully executed");
    }
}
