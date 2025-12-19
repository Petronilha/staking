// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {Test} from "forge-std/Test.sol";
import {NftStaker} from "../src/staking.sol";
import {ERC1155} from "../lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC1155 is ERC1155 {
    constructor() ERC1155("") {}
    
    // Mint function for testing purposes
    function mint(address to, uint256 id, uint256 amount) public {
        _mint(to, id, amount, "");
    }
}

contract MockERC20 is ERC20 {
    constructor() ERC20("MockToken", "MTK") {}
    
    // Mint function for testing purposes
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract stakingTest is Test {
    NftStaker public staker;
    MockERC1155 public mockNft;
    MockERC20 public mockToken;

    function setUp() public {
        // Deploy mock contracts
        mockNft = new MockERC1155();
        mockToken = new MockERC20();

        staker = new NftStaker(address(mockNft), address(mockToken));
    }

    function testInitialStakingTime() public view {
        // Verify that the initial staking time for a new user is zero
        uint256 initialStakingTime = staker.stakingTime(address(this));
        assertEq(initialStakingTime, 0, "Initial staking time should be zero");
    }

    // Test staking functionality
    function testStake() public {
        // Test staking functionality
        uint256 tokenId = 1;
        uint256 amount = 5;

        // Mint some NFTs to this contract
        mockNft.mint(address(this), tokenId, amount);

        // Approve the staker contract to transfer NFTs
        mockNft.setApprovalForAll(address(staker), true);

        // Call the stake function
        staker.stake(tokenId, amount);

        // Retrieve the stake info
        (uint256 stakedTokenId, uint256 stakedAmount, uint256 timestamp) = staker.stakes(address(this));

        // Verify the stake info
        assertEq(stakedTokenId, tokenId, "Staked token ID should match");
        assertEq(stakedAmount, amount, "Staked amount should match");
        assertGt(timestamp, 0, "Timestamp should be greater than zero");
    }

    function testUnstake() public {
        // Test unstaking functionality
        uint256 tokenId = 1;
        uint256 amount = 5;

        // Mint some NFTs to this contract
        mockNft.mint(address(this), tokenId, amount);

        // Approve the staker contract to transfer NFTs
        mockNft.setApprovalForAll(address(staker), true);

        // Call the stake function
        staker.stake(tokenId, amount);

        // Fast forward time by 1 day
        vm.warp(block.timestamp + 1 days);

        // Call the unstake function
        staker.unstake();

        // Verify that the stake has been cleared
        (uint256 stakedTokenId, uint256 stakedAmount, ) = staker.stakes(address(this));
        assertEq(stakedTokenId, 0, "Staked token ID should be zero after unstaking");
        assertEq(stakedAmount, 0, "Staked amount should be zero after unstaking");

        // Verify that the staking time has been updated
        uint256 totalStakingTime = staker.stakingTime(address(this));
        assertEq(totalStakingTime, 1 days, "Total staking time should be 1 day");
    }

    function testRewardMinusMonth() public {
        // Test reward functionality
        uint256 tokenId = 1;
        uint256 amount = 5;

        // Mint some NFTs to this contract
        mockNft.mint(address(this), tokenId, amount);

        // Approve the staker contract to transfer NFTs
        mockNft.setApprovalForAll(address(staker), true);

        // Mint some reward tokens to the staker contract
        mockToken.mint(address(staker), 10 * 10 ** 18);

        // Call the stake function
        staker.stake(tokenId, amount);

        // Fast forward time by 31 seconds to be eligible for reward
        vm.warp(block.timestamp + 31 seconds);

        // Call the reward function
        staker.reward();

        // Verify that the reward tokens have been transferred
        uint256 rewardBalance = mockToken.balanceOf(address(this));
        assertEq(rewardBalance, 10 * 10 ** 18, "Reward balance should be 10 tokens");
    }

    function testRewardPlusMonth() public {
        uint256 tokenId = 1;
        uint256 amount = 5;

        // Mint some NFTs to this contract
        mockNft.mint(address(this), tokenId, amount);

        // Approve the staker contract to transfer NFTs
        mockNft.setApprovalForAll(address(staker), true);

        // Mint some reward tokens to the staker contract
        mockToken.mint(address(staker), 20 * 10 ** 18);

        // Call the stake function
        staker.stake(tokenId, amount);

        // Fast forward time by 31 days to be eligible for higher reward
        vm.warp(block.timestamp + 31 days);

        // Call the reward function
        staker.reward();

        // Verify that the reward tokens have been transferred
        uint256 rewardBalance = mockToken.balanceOf(address(this));
        assertEq(rewardBalance, 20 * 10 ** 18, "Reward balance should be 20 tokens");
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }
}