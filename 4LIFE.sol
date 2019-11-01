pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 */
contract ReentrancyGuard {
    // counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 */

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on overflow (when the result is negative).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the division of two unsigned integers, reverting on division by zero.
     * The result is rounded towards zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    /**
     * @dev Returns the division of two unsigned integers, reverting on division by zero.
     * The result is rounded towards infinity.
     */
    function divRound(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        if (a % b != 0) {
            c = c + 1;
        }

        return c;
    }
}

/**
 * @dev Interface of the ERC20 standard
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens of `spender`
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account `from` to another `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the name
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

/**
 * @dev 4LIFE Token
 */
contract ForLIFEToken is Ownable, ReentrancyGuard, ERC20Detailed {

    using SafeMath for uint256;

    /**
     * Token metadata
     */
    string private _tokenName = "4LIFE";
    string private _tokenSymbol = "4LIFE";
    uint8 private _tokenDecimals = 8;

    /**
     * Pond management
     * TO-DO    -    add the main wallet address
     */
    address payable pond;
    uint256 private _rate = 5500000000000;
    uint256 private _ratePerTokenSubdivision = _rate.div(10**8);

    /**
     * Token management
     */
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    uint256 private _tokenAmount = 10000000;
    uint256 private _totalSupply = _tokenAmount.mul(10**8);
    uint256 private _percent = 2;

    /**
     * Events
     */
    event PondAddressSet(address indexed previousPond, address indexed newPond);
    event PondRateSet(uint256 previousRate, uint256 newRate);
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /**
     * @dev Create the token
     */
    constructor (address payable _pondAddress) public payable ERC20Detailed(_tokenName, _tokenSymbol, _tokenDecimals) {
        require(_pondAddress != address(0), "4LIFE: Pond address is address(0)");

        emit PondAddressSet(address(0), _pondAddress);
        pond = _pondAddress;
        _balances[pond] = _totalSupply;

        emit Transfer(address(0), pond, _totalSupply);
    }

    /**
     * @dev Returns percentage `b` amount from value `a`
     */
    function percVal(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a.mul(b).div(100);

        return c;
    }

    /**
     * @dev Returns `pond` address
     */
    function getPond() public view returns (address) {

        return pond;
    }

    /**
     * @dev Set `pond` address
     * Only contract owner can do it
     */
    function setPond(address payable pondAddress) public onlyOwner {
        _setPond(pondAddress);
    }

    function _setPond(address payable _pondAddress) internal {
        require(_pondAddress != address(0), "4LIFE: Pond address is address(0)");
        emit PondAddressSet(pond, _pondAddress);
        pond = _pondAddress;
    }

    /**
     * @dev Returns `_rate`
     */
    function getRate() public view returns (uint256) {

        return _rate;
    }

    /**
     * @dev Set `_rate`
     * Only contract owner can do it
     */
    function setRate(uint256 sellRate) public onlyOwner {
        _setRate(sellRate);
    }

    function _setRate(uint256 _sellRate) internal {
        require(_sellRate > 0, "4LIFE: Rate is 0");
        emit PondRateSet(_rate, _sellRate);
        _rate = _sellRate;
    }

    /**
     * @dev Returns the total supply
     */
    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    /**
     * @dev Returns the balance of the `account` provided
     */
    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function allowance(address account, address spender) public view returns (uint256) {

        return _allowed[account][spender];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(amount <= _balances[msg.sender], "4LIFE: Not enough funds");
        require(to != address(0), "4LIFE: Transfer to address(0)");

        uint256 tokensToBurn = percVal(amount, _percent);
        uint256 tokensToPond = tokensToBurn;
        uint256 tokensToTransfer = amount.sub(tokensToBurn).sub(tokensToPond);

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[to] = _balances[to].add(tokensToTransfer);
        _balances[pond] = _balances[pond].add(tokensToPond);
        _totalSupply = _totalSupply.sub(tokensToBurn);

        emit Transfer(msg.sender, to, tokensToTransfer);
        emit Transfer(msg.sender, pond, tokensToPond);
        emit Transfer(msg.sender, address(0), tokensToBurn);

        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "4LIFE: Approve for address(0)");

        _allowed[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(amount <= _balances[from], "4LIFE: Not enough funds");
        require(amount <= _allowed[from][msg.sender], "4LIFE: Not enough allowance");
        require(to != address(0), "4LIFE: Transfer to address(0)");

        uint256 tokensToBurn = percVal(amount, _percent);
        uint256 tokensToPond = tokensToBurn;
        uint256 tokensToTransfer = amount.sub(tokensToBurn).sub(tokensToPond);

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(tokensToTransfer);
        _balances[pond] = _balances[pond].add(tokensToPond);
        _totalSupply = _totalSupply.sub(tokensToBurn);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(amount);

        emit Transfer(from, to, tokensToTransfer);
        emit Transfer(from, pond, tokensToPond);
        emit Transfer(from, address(0), tokensToBurn);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0), "4LIFE: Increase allowance to address(0)");

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0), "4LIFE: Decrease allowance to address(0)");

        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;
    }

    /**
     * @dev Accept eth
     */
    function () external payable {
        buyTokens(msg.sender);
    }

    /**
     * @dev Handle eth coming in and send back tokens
     */
    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        require(beneficiary != address(0), "4LIFE: Buyer is address(0)");
        require(weiAmount > _ratePerTokenSubdivision, "4LIFE: weiAmount is to small");

        // Get token units to handle
        uint256 tokenAmount = weiAmount.div(_ratePerTokenSubdivision);
        uint256 tokensToBurn = percVal(tokenAmount, _percent);
        uint256 tokensToPond = tokensToBurn;
        uint256 tokensToTransfer = tokenAmount.sub(tokensToBurn).sub(tokensToPond);

        // adjust token balances
        _balances[pond] = _balances[pond].sub(tokenAmount);
        _balances[msg.sender] = _balances[msg.sender].add(tokensToTransfer);
        _balances[pond] = _balances[pond].add(tokensToPond);
        _totalSupply = _totalSupply.sub(tokensToBurn);

        emit Transfer(pond, msg.sender, tokensToTransfer);
        emit Transfer(pond, pond, tokensToPond);
        emit Transfer(pond, address(0), tokensToBurn);

        // Forward funds
        pond.transfer(msg.value);
    }
}