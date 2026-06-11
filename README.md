# dead-mans-switch

A blockchain-based dead mans switch built on Ethereum. The owner must check-in regularly to prove that they are alive. If they stop checking in, then the funds are automatically released to the designated beneficiaries, without any intermediates. The code enforces everything.

# working-mechanism

1. Owner deploys the contract and deposits ETH.
2. The owner assigns beneficiaries and a share percent to each of them. (The sum of share percentages must be 100)
3. Every hour, the function checkIn() must be called to prove that they are alive.
4. If the owner misses a check in, anyone can call triggerGracePeriod().
5. This grants the owner a 30 minute grace period to check-in and reset the clock.
6. Once the grace period expires, the beneficiaries can claim() their respective sharees.
7. At any point of time while in Active or in Grace period, the owner can cancel and withdraw everything.

# contract-addresses

| Contract       | Address                                      |
|----------------|----------------------------------------------|
| DeadMansSwitch | `0x26eaCe350b0304Ce9820B9E0E8f15453AC9C1319` | 
| SwitchFactory  | `0xE7A42A30Cd6714e91CF0a1f077D27ADf0045c271` |

# project-structure

src/
DeadMansSwitch.sol
IDeadMansSwitch.sol
SwitchFactory.sol
test/
DeadMansSwitch.t.sol
frontend/
index.html
script/
Deploy.s.sol

# contract-features

1. Reentrancy protection via OpenZeppelin ReentrancyGuard.
2. Customizable check-in interval and grace period.
3. Factory pattern for deploying multiple switches.
4. Access control via modifiers.
5. ETH and ERC-20 token support.

# prerequisites

1. Foundry - https://getfoundry.sh/
2. Metamask - http://metamask.io/
3. Sepolia testnet ETH from faucet - https://cloud.google.com/application/web3/faucet/ethereum/sepolia/

# installation-command

```bash
   git clone https://github.com/DracarysMalfoy/dead-mans-switch/
   cd dead-mans-switch
   forge install
```

# test-commands

```bash
   forge test
```

# test-coverage-results

current coverage: 82.54% lines, 91.67% functions 

# deployment

1. Set the environment variables:
```bash
   export PRIVATE_KEY=your_private_key
   export RPC_URL=https://ethereum-sepolia-rpc.publicnode.com
   export ETHERSCAN_API_KEY=your_etherscan_api_key
```

2. Deploy and verify:
```bash
   forge script script/Deploy.s.sol \
     --rpc-url $RPC_URL \
     --private-key $PRIVATE_KEY \
     --broadcast \
     --verify \
     --etherscan-api-key $ETHERSCAN_API_KEY \
     --chain sepolia
```

# opening-frontend

```bash
  cd frontend
  python3 -m http.server 8080
```
(Open port 8080 in your browser and connect MetaMask on Sepolia network.)

# frontend-features

1. Owner Panel
   - Connect wallet
   - Live contract status with countdown timer
   - Check In button
   - Deposit ETH
   - Add and remove beneficiaries
   - Cancel switch with confirmation

2. Beneficiary Panel
   - Look up any switch by contract address
   - See time remaining before claim is possible
   - Claim button enabled when funds are claimable
   - View share percentage

3. Factory Panel
   - Deploy new switch instances
   - List all switches owned by connected wallet

# tech-stack

| Tool            | Purpose                         |
|-----------------|---------------------------------|
| Solidity 0.8.35 | Smart contract language         |
| Foundry         | Testing and deployment          |
| OpenZeppelin    | ReentrancyGuard                 |
| ethers.js v6    | Frontend blockchain interaction |
| Sepolia         | Ethereum testnet                |

# license

MIT

EOF



