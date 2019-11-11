pragma solidity ^0.5.0;

import "./flashloan/base/FlashLoanReceiverBase.sol";
import "./configuration/LendingPoolAddressesProvider.sol";
import "./configuration/NetworkMetadataProvider.sol";

interface CTokenInterface {
    function mint(uint mintAmount) external returns (uint); // For ERC20
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function exchangeRateCurrent() external returns (uint);
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function balanceOf(address) external view returns (uint);
}

interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

interface Compound{
    function liquidateBorrow(address borrower, uint repayAmount) external returns (uint);
}

contract FlashLoanLiquidator is FlashLoanReceiverBase{

    using SafeMath for uint256;



    constructor(LendingPoolAddressesProvider _provider) FlashLoanReceiverBase(_provider)
        public {}

    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee) external returns(uint256 returnedAmount) {

        require(_amount <= getBalanceInternal(address(this), _reserve),
            "Invalid balance for the contract");

        ERC20 token = ERC20(0xbF7A7169562078c96f0eC1A8aFD6aE50f12e5A99);
        Compound compoundliq = Compound(0x0A1e4D0B5c71B955c0a5993023fc48bA6E380496); // CDAI contract

        // Approve tokens to Compound address
        token.approve(0x0A1e4D0B5c71B955c0a5993023fc48bA6E380496, _amount);

        // HARDCODED ADDRESS OF USER TO LIQUIDATE
        compoundliq.liquidateBorrow(0x94b0228f66593EE661e8aaD8d9fFb52a1F298b9c, _amount);
        

        // Pays back
        transferFundsBackToPoolInternal(_reserve, _amount.add(_fee));
        return _amount.add(_fee);
    }
}