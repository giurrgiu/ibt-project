// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IBT is ERC20, Ownable {
    uint256 public nonce;

    event BridgedOut(
        address indexed from,
        uint256 amount,
        bytes suiRecipient,
        uint256 nonce
    );

    constructor()
        ERC20("Introduction to Blockchain Technologies", "IBT")
        Ownable(msg.sender)
    {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function bridgeOut(uint256 amount, bytes calldata suiRecipient) external {
        require(amount > 0, "amount=0");
        _burn(msg.sender, amount);
        emit BridgedOut(msg.sender, amount, suiRecipient, nonce);
        nonce++;
    }
}
//0xa259c6412e47de9c0aa85008487a892dff2ea64345591170cf01d0256b0d7de5
