const provider = new ethers.providers.Web3Provider(window.ethereum);
const signer = provider.getSigner();

const contractAddress = "YOUR_CONTRACT_ADDRESS";
const abi = [
    // Add the ABI of your contract here
    {
        "inputs": [],
        "name": "kill",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "nonce",
                "type": "uint256"
            },
            {
                "internalType": "bytes",
                "name": "sig",
                "type": "bytes"
            }
        ],
        "name": "claimPayment",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
];

const contract = new ethers.Contract(contractAddress, abi, signer);

// Function to claim payment
async function claimPayment() {
    const amount = document.getElementById("amount").value;
    const nonce = document.getElementById("nonce").value;
    const signature = document.getElementById("signature").value;

    try {
        const tx = await contract.claimPayment(amount, nonce, signature);
        await tx.wait();
        document.getElementById("claimResult").innerText = "Payment claimed successfully!";
    } catch (error) {
        console.error(error);
        document.getElementById("claimResult").innerText = "Failed to claim payment.";
    }
}

// Function to kill the contract
async function killContract() {
    try {
        const tx = await contract.kill();
        await tx.wait();
        document.getElementById("killResult").innerText = "Contract destroyed successfully!";
    } catch (error) {
        console.error(error);
        document.getElementById("killResult").innerText = "Failed to destroy contract.";
    }
}
