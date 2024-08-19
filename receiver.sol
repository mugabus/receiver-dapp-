// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReceiverPays {
    address public owner;
    mapping(uint256 => bool) usedNonces;

    // Constructor sets the owner and accepts funds at deployment time.
    constructor() payable {
        owner = msg.sender;
    }

    // Function to claim payment
    function claimPayment(uint256 amount, uint256 nonce, bytes memory sig) public {
        require(!usedNonces[nonce], "Nonce already used");
        usedNonces[nonce] = true;

        // This recreates the message that was signed on the client.
        bytes32 message = prefixed(keccak256(abi.encodePacked(msg.sender, amount, nonce, this)));

        require(recoverSigner(message, sig) == owner, "Invalid signature");

        payable(msg.sender).transfer(amount);
    }

    // Destroy contract and reclaim leftover funds.
    function kill() public {
        require(msg.sender == owner, "Only the owner can destroy the contract");
        selfdestruct(payable(msg.sender));
    }

    // Signature methods

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65, "Invalid signature length");

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}
