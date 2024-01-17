# 练习题（01.17）

### **将练习题（01.16）的项目用foundry进行测试**

#### 测试用例代码如下：

**ERC777TokenGTT.t.sol**

```solidity
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
        nftContract.mint(bob, "No.0");
        tokenContract.approve(marketAddr, 10000 * 10 ** 18);
        vm.startPrank(bob);
        nftContract.approve(marketAddr, 0);
        nftMarketContract.list(nftAddr, 0, 100 * 10 ** 18);
        vm.stopPrank();
        bytes memory _data = abi.encode(0, nftAddr);
        vm.prank(alice);
        tokenContract.transferWithCallbackForNFT(
            marketAddr,
            101 * 10 ** 18,
            _data
        );
        assertEq(
            nftContract.ownerOf(0),
            alice,
            "expect the current owner of #0 NFT is alice after transferring token to NFTMarket"
        );
    }
}
```

**ERC721Token.t.sol**

```solidity
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
```

**NFTMarket.t.sol**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../src/NFTMarket.sol";
import "../src/ERC777TokenGTT.sol";
import "../src/ERC721Token.sol";

contract NFTMarketTest is Test {
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

    function test_NFTMarket_List() public {
        vm.startPrank(alice);
        nftContract.mint(alice, "No.0");
        nftContract.mint(bob, "No.1");
        nftContract.mint(carol, "No.2");
        nftContract.approve(marketAddr, 0);
        nftMarketContract.list(nftAddr, 0, 100 * 10 ** 18);
        vm.stopPrank();
        assertEq(
            nftContract.ownerOf(0),
            marketAddr,
            "expect the current owner of #0 NFT is NFTMarket"
        );
        assertEq(
            nftContract.getApproved(0),
            alice,
            "expect the current approved account is alice"
        );
        assertTrue(
            nftMarketContract.onSale(nftAddr, 0),
            "expect #0 NFT is listed"
        );
    }

    function test_NFTMarket_Buy() public {
        vm.startPrank(alice);
        nftContract.mint(alice, "No.0");
        nftContract.mint(bob, "No.1");
        nftContract.approve(marketAddr, 0);
        tokenContract.approve(marketAddr, 10000 * 10 ** 18);
        nftMarketContract.list(nftAddr, 0, 100 * 10 ** 18);
        vm.stopPrank();
        vm.startPrank(bob);
        nftContract.approve(marketAddr, 1);
        tokenContract.approve(marketAddr, 10000 * 10 ** 18);
        nftMarketContract.list(nftAddr, 1, 200 * 10 ** 18);
        vm.stopPrank();
        vm.prank(alice);
        nftMarketContract.buy(nftAddr, 1, 201 * 10 ** 18);
        vm.prank(bob);
        nftMarketContract.buy(nftAddr, 0, 101 * 10 ** 18);
        assertEq(
            nftContract.ownerOf(0),
            bob,
            "expect the current owner of #0 NFT is bob after buying"
        );
        assertEq(
            nftContract.ownerOf(1),
            alice,
            "expect the current owner of #1 NFT is alice after buying"
        );
    }

    function test_NFTMarket_OwnerBuyNFT_ExpectRevert() public {
        vm.startPrank(alice);
        nftContract.mint(alice, "No.0");
        nftContract.approve(marketAddr, 0);
        tokenContract.approve(marketAddr, 10000 * 10 ** 18);
        nftMarketContract.list(nftAddr, 0, 100 * 10 ** 18);
        vm.expectRevert("Owner cannot buy!");
        nftMarketContract.buy(nftAddr, 0, 101 * 10 ** 18);
        vm.stopPrank();
    }

    function test_NFTMarket_tokensReceived() public {
        vm.startPrank(alice);
        nftContract.mint(bob, "No.0");
        tokenContract.approve(marketAddr, 10000 * 10 ** 18);
        vm.startPrank(bob);
        nftContract.approve(marketAddr, 0);
        nftMarketContract.list(nftAddr, 0, 100 * 10 ** 18);
        vm.stopPrank();
        bytes memory _data = abi.encode(0, nftAddr);
        vm.prank(alice);
        nftMarketContract.tokensReceived(
            alice,
            marketAddr,
            101 * 10 ** 18,
            _data
        );
        assertEq(
            nftContract.ownerOf(0),
            alice,
            "expect the current owner of #0 NFT is alice after transferring token to NFTMarket"
        );
    }
}
```

