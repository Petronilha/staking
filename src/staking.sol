// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.29;

import "../lib/openzeppelin-contracts/contracts/token/ERC1155/IERC1155.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC1155/IERC1155Receiver.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/// @title NFT Staking Contract
/// @author Daniel Petronilha
/// @notice A contract for staking ERC1155 NFTs and receiving rewards in ERC20 tokens based on staking duration
contract NftStaker {
  IERC1155 public parentNFT;

  IERC20 public token;

  struct Stake {
    uint256 tokenId;
    uint256 amount;
    uint256 timestamp;
  }

  /// @notice Mapping staker address to stake info
  mapping(address staker => Stake stakeInfo) public stakes;

  /// @notice Mapping staker address to total staking time
  mapping(address staker => uint256 totalStakingTime) public stakingTime;

  constructor(address contrato, address rewardToken) {
    parentNFT = IERC1155(contrato);
    token = IERC20(rewardToken);
  }

  /// @notice Stake NFTs
  /// @param _tokenId The ID of the NFT to stake
  /// @param _amount The amount of NFTs to stake
  function stake(uint256 _tokenId, uint256 _amount) public {
    require(_amount > 0, "Amount must be greater than 0");
    parentNFT.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "0x00");
    stakes[msg.sender] = Stake({
      tokenId: _tokenId,
      amount: _amount,
      timestamp: block.timestamp
    });
  }

  /// @notice Unstake NFTs
  function unstake() public {
    Stake memory userStake = stakes[msg.sender];
    require(userStake.amount > 0, "No active stake found");

    // Calculate staking duration
    uint256 stakingDuration = block.timestamp - userStake.timestamp;
    stakingTime[msg.sender] += stakingDuration;

    // Transfer the staked NFTs back to the user
    parentNFT.safeTransferFrom(address(this), msg.sender, userStake.tokenId, userStake.amount, "0x00");

    // Clear the stake
    delete stakes[msg.sender];
  }

  /// @notice Claim rewards based on staking duration
  function reward() external {
    require(stakes[msg.sender].timestamp + 30 seconds <= block.timestamp, "no reward");
    if(stakes[msg.sender].timestamp + 30 days >= block.timestamp) {
      token.transfer(msg.sender, 10 * 10 ** 18);
    }

    if(stakes[msg.sender].timestamp + 30 days <= block.timestamp) {
      token.transfer(msg.sender, 20 * 10 ** 18);
    }
  }

  /// @notice Handle the receipt of a single ERC1155 token type
  /// @dev Required for the contract to be able to receive ERC1155 tokens
  function onERC1155Received(
    address,
    address,
    uint256,
    uint256,
    bytes calldata
  )
  external pure  returns (bytes4) {
    return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
  }

}