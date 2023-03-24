pragma solidity ^0.8.0;
// import "@openzeppelin/contracts/access/Ownable.sol";
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract Wallet {
    address payable owner;
    uint256 etherFee;
    uint256 ercFee;


    constructor() {
        owner = payable(msg.sender);
        etherFee = 1;
        ercFee = 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function setEtherFee(uint256 _feePercent) public onlyOwner {
        etherFee = _feePercent;
    }
    function setErcFee(uint256 _feePercent) public onlyOwner {
        ercFee = _feePercent;
    }

    function transferEther(address payable recipient) public payable {
        uint256 fee = (msg.value * etherFee) / 100;
        uint256 amount = msg.value - fee;
        recipient.transfer(amount);
        owner.transfer(fee);
    }

    function transferToken(IERC20 token, address recipient, uint256 amount) public {
        uint256 fee = (amount * ercFee) / 100;
        amount = amount - fee;
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount+fee, "Allowance not enough");
        bool success = token.transferFrom(msg.sender, recipient, amount);
        require(success, "Transfer failed");
    }

    function approveToken(IERC20 token, address spender, uint256 amount) public {
        bool success = token.approve(spender, amount);
        require(success, "Approve failed");
    }

    function transferApprovedToken(IERC20 token, address recipient, uint256 amount) public {
        bool success = token.transferFrom(msg.sender, recipient, amount);
        require(success, "Transfer failed");
    }
}
