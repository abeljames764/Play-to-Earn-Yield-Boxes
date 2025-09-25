# 🎵 Play-to-Earn Yield Boxes 📦

> *Boombox-like NFTs that accrue stacking rewards on Bitcoin L2* 🎧⚡

## 🌟 Overview

Play-to-Earn Yield Boxes are unique NFT collectibles that function like digital boomboxes, generating passive STX rewards while you hold and stake them. Each Yield Box has different rarities and multipliers, making them valuable assets in the Stacks ecosystem.

## ✨ Features

- 🎯 **NFT Minting**: Create unique Yield Boxes with different rarity levels
- 📈 **Staking Mechanism**: Stake your NFTs to earn continuous rewards
- 🎁 **Reward Accrual**: Earn STX tokens based on rarity multipliers and staking duration
- 🔄 **Transfer System**: Trade your Yield Boxes with automatic unstaking
- 📊 **User Statistics**: Track your collection and total earnings
- 💎 **Rarity System**: Common, Rare, Epic, and Legendary tiers with different multipliers

## 🎮 How It Works

### 🎪 Rarity Multipliers
- 🥉 **Common**: 1x multiplier
- 🥈 **Rare**: 2x multiplier  
- 🥇 **Epic**: 3x multiplier
- 💎 **Legendary**: 5x multiplier

### 💰 Rewards Formula
```
Rewards = Blocks Staked × Base Rate × Rarity Multiplier
```

## 🚀 Getting Started

### Prerequisites
- 📋 [Clarinet](https://github.com/hirosystems/clarinet) installed
- 🌐 Stacks wallet (Hiro Wallet, Xverse, etc.)
- 💻 Basic understanding of Clarity smart contracts

### 🛠️ Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd Play-to-Earn-Yield-Boxes
```

2. **Initialize Clarinet project**
```bash
clarinet new yield-boxes
cp contracts/yield-boxes.clar yield-boxes/contracts/
```

3. **Test the contract**
```bash
clarinet test
```

4. **Deploy to testnet**
```bash
clarinet deploy --testnet
```

## 📖 Usage Guide

### 🎨 For Contract Owner

#### Mint a Yield Box
```clarity
(contract-call? .yield-boxes mint-yield-box 'SP1234... "rare")
```

#### Set Reward Rate
```clarity
(contract-call? .yield-boxes set-base-reward-rate u200)
```

#### Fund Contract with Rewards
```clarity
(contract-call? .yield-boxes deposit-rewards u1000000)
```

### 👥 For Users

#### Start Staking Your Yield Box
```clarity
(contract-call? .yield-boxes start-staking u1)
```

#### Check Your Rewards
```clarity
(contract-call? .yield-boxes calculate-rewards u1)
```

#### Claim Your Rewards
```clarity
(contract-call? .yield-boxes claim-rewards u1)
```

#### Stop Staking
```clarity
(contract-call? .yield-boxes stop-staking u1)
```

#### View Your Stats
```clarity
(contract-call? .yield-boxes get-user-stats tx-sender)
```

## 🔍 Contract Functions

### 📝 Public Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `mint-yield-box` | Mint new NFT (owner only) | `recipient`, `rarity` |
| `start-staking` | Begin earning rewards | `token-id` |
| `stop-staking` | Stop earning rewards | `token-id` |
| `claim-rewards` | Withdraw earned STX | `token-id` |
| `deposit-rewards` | Add STX to reward pool | `amount` |
| `transfer` | Transfer NFT ownership | `token-id`, `sender`, `recipient` |

### 👀 Read-Only Functions

| Function | Description | Returns |
|----------|-------------|---------||
| `get-token-metadata` | Get NFT details | Rarity, multiplier, creation block |
| `get-staking-data` | Get staking status | Stake time, rewards claimed, active status |
| `get-user-stats` | Get user statistics | Boxes owned, total rewards, staking count |
| `calculate-rewards` | Calculate pending rewards | Reward amount |
| `get-contract-balance` | Get available reward pool | STX balance |

## 🎯 Example Workflow

1. **🎪 Owner mints Yield Boxes**
   ```clarity
   (contract-call? .yield-boxes mint-yield-box 'SP1ABCD... "legendary")
   ```

2. **💰 Owner funds reward pool**
   ```clarity
   (contract-call? .yield-boxes deposit-rewards u5000000)
   ```

3. **📦 User starts staking**
   ```clarity
   (contract-call? .yield-boxes start-staking u1)
   ```

4. **⏰ Time passes... blocks accumulate...**

5. **💸 User claims rewards**
   ```clarity
   (contract-call? .yield-boxes claim-rewards u1)
   ```

## 🧪 Testing

Run the test suite to verify contract functionality:

```bash
clarinet test
```

## 🤝 Contributing

We welcome contributions! Please feel free to submit issues and pull requests.

1. 🍴 Fork the repository
2. 🌟 Create your feature branch
3. 💾 Commit your changes
4. 🚀 Push to the branch
5. 📨 Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Links

- 🌐 [Stacks Blockchain](https://stacks.co)
- 📚 [Clarity Documentation](https://docs.stacks.co/clarity)
- 🛠️ [Clarinet](https://github.com/hirosystems/clarinet)

---

**🎵 Start your Play-to-Earn journey with Yield Boxes today! 📦✨**

# Play-to-Earn Yield Boxes

