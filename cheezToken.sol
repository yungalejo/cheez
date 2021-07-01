// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract CheezDispenser {
    struct Claim {
        bool claimed;
        uint256 ratId;
    }

    mapping(uint256 => Claim) public existingClaims;
    
    ERC721 ratContract = ERC721(0x089c1db714d64241192C515c0B36Ca07CA62E7AD);
    ERC20 cheezContract = ERC20(0x2a1E167cB8D15d35fB619Af1e7f05EB8D9707205);

    bool paused=false;
    address deployer;
    uint256 amount = 100 * (1 ether);

    event Dispense(uint256 amount, uint256 ratId);

    constructor() {
        deployer = msg.sender;
    }

    modifier onlyDeployer() {
        require(msg.sender == deployer);
        _;
    }

    modifier pauseable() {
        require(paused == false, "contract is paused");
        _;
    }
    
    function pause() public onlyDeployer {
        paused = true;
    }

    function unpause() public onlyDeployer {
        paused = false;
    }

    function setAmount(uint256 newAmount) public onlyDeployer pauseable {
        amount = newAmount;
    }

    function claimCheez(uint256 ratId) public pauseable {
        Claim memory claim = existingClaims[ratId];
        require(claim.claimed == false, 'coins have already been claimed for this ratId');

        address ratOwner = ratContract.ownerOf(ratId);
        require(msg.sender == ratOwner, 'Caller is not owner of this token ID');

        existingClaims[ratId] = Claim(true, ratId);
        cheezContract.transfer(msg.sender, amount);

        emit Dispense(amount, ratId);
    }


    function withdraw(uint256 withdrawAmount) public onlyDeployer {
        cheezContract.transfer(msg.sender, withdrawAmount);
    }
    
}

abstract contract ERC721 {
    function ownerOf(uint256 id) public virtual returns (address);
}

abstract contract ERC20 {
    function transfer(
        address to,
        uint256 value
    ) public virtual;
}