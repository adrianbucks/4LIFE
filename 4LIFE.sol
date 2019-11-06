pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
 * @dev Wrappers over Solidity's arithmetic operations with added overflow checks.
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
    address payable private _pond; // charity wallet
    uint256 private _saleRate = 5500000000000; // WEI
    uint256 private _minWeiForPondEntry = 250000000000000000; // WEI
    uint256 private _minWeiForDiscount = 10000000000000000000; // WEI
    uint256 private _premium = 7; //%
    uint256 private _discount = 25; // %
    // Uses 0 for none, 1 for Ducks, 2 for Swans
    mapping (address => uint256) private _PondFamily;
    mapping (uint256 => address) private _PondID;
    uint256 private _totalPondMembers = 0;
    uint256 private _weiRaised = 0;
    uint256 private _highestDeposit = 0;
    address private _highestDepositAddress = address(0);
    uint256 private _nounce;

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
    event PondAddressChanged(address indexed previousPond, address indexed newPond);
    event SaleRateChanged(uint256 previousRate, uint256 newRate);
    event MinimumAmountForPondEntryChanged(uint256 previousEntryAmount, uint256 newEntryAmount);
    event MinimumAmountForDiscountChanged(uint256 previousDicountAmount, uint256 newDiscountAmount);
    event DiscountPercentageChanged(uint256 previousDiscount, uint256 newDiscount);
    event PremiumPercentageChanged(uint256 previousPremium, uint256 newPremium);
    event NewHighestDeposit(address indexed prevAddress, address indexed newAddress, uint256 prevAmount, uint256 newAmount);
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /**
     * @dev Create the token
     */
    constructor (address payable _pondAddress) public payable ERC20Detailed(_tokenName, _tokenSymbol, _tokenDecimals) {
        require(_pondAddress != address(0), "4LIFE: Pond address is address(0)");

        emit PondAddressChanged(address(0), _pondAddress);
        _pond = _pondAddress;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
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
    function getPondAddress() public view returns (address) {
        return _pond;
    }

    /**
     * @dev Set `pond` address
     * Only contract owner can do it
     */
    function setPondAddress(address payable pondAddress) public onlyOwner {
        _setPondAddress(pondAddress);
    }
    function _setPondAddress(address payable _pondAddress) internal {
        require(_pondAddress != address(0), "4LIFE: Pond address is address(0)");
        emit PondAddressChanged(_pond, _pondAddress);
        _pond = _pondAddress;
    }

    /**
     * @dev Returns the rate (in WEI) the token is on sale at
     */
    function getSaleRate() public view returns (uint256) {
        return _saleRate;
    }

    /**
     * @dev Set the rate (in WEI) the token is on sale at
     * Only contract owner can do it
     */
    function setSaleRate(uint256 rate) public onlyOwner {
        _setSaleRate(rate);
    }
    function _setSaleRate(uint256 _rate) internal {
        require(_rate > 1*10**8, "4LIFE: Rate is less than 1 WEI per token subdivision");
        emit SaleRateChanged(_saleRate, _rate);
        _saleRate = _rate;
    }

    /**
     * @dev Return the minimum amount (in WEI) required to spend to be added to the Pond
     */
    function getMinAmountForPondEntry() public view returns (uint256) {
        return _minWeiForPondEntry;
    }

    /**
     * @dev Set the minimum amount (in WEI) required to spend to be added to the Pond
     */
    function setMinAmountForPondEntry(uint256 amountForEntry) public onlyOwner {
        _setMinAmountForPondEntry(amountForEntry);
    }
    function _setMinAmountForPondEntry(uint256 _amountForEntry) internal {
        require(_amountForEntry >= _saleRate, "4LIFE: Amount is less than the sale rate for 1 token");
        emit MinimumAmountForPondEntryChanged(_minWeiForPondEntry, _amountForEntry);
        _minWeiForPondEntry = _amountForEntry;
    }

    /**
     * @dev Return the minimum amount (in WEI) required to spend to get the discount
     */
    function getMinAmountForDiscount() public view returns (uint256) {
        return _minWeiForDiscount;
    }

    /**
     * @dev Set the minimum amount (in WEI) required to spend to be added to the Pond
     */
    function setMinAmountForDiscount(uint256 amountForDiscount) public onlyOwner {
        _setMinAmountForDiscount(amountForDiscount);
    }
    function _setMinAmountForDiscount(uint256 _amountForDiscount) internal {
        require(_amountForDiscount >= _minWeiForPondEntry.mul(2), "4LIFE: Amount is less than double of minimum amount for Pond entry");
        emit MinimumAmountForDiscountChanged(_minWeiForDiscount, _amountForDiscount);
        _minWeiForDiscount = _amountForDiscount;
    }

    /**
     * @dev Return the discount percentage
     */
    function getDiscountPercentage() public view returns (uint256) {
        return _discount;
    }

    /**
     * @dev Set the discount percentage
     */
    function setDiscountPercentage(uint256 discountPercentage) public onlyOwner {
        _setDiscountPercentage(discountPercentage);
    }
    function _setDiscountPercentage(uint256 _discountPercentage) internal {
        require(_discountPercentage > 0, "4LIFE: Discount is 0");
        emit DiscountPercentageChanged(_discount, _discountPercentage);
        _discount = _discountPercentage;
    }

    /**
     * @dev Return the premium percentage
     */
    function getPremiumPercentage() public view returns (uint256) {
        return _premium;
    }

    /**
     * @dev Set the premium percentage
     */
    function setPremiumPercentage(uint256 premiumPercentage) public onlyOwner {
        _setPremiumPercentage(premiumPercentage);
    }
    function _setPremiumPercentage(uint256 _premiumPercentage) internal {
        require(_premiumPercentage > 0, "4LIFE: Premium is 0");
        emit PremiumPercentageChanged(_premium, _premiumPercentage);
        _premium = _premiumPercentage;
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
        _balances[_pond] = _balances[_pond].add(tokensToPond);
        _totalSupply = _totalSupply.sub(tokensToBurn);

        emit Transfer(msg.sender, to, tokensToTransfer);
        emit Transfer(msg.sender, _pond, tokensToPond);
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
        _balances[_pond] = _balances[_pond].add(tokensToPond);
        _totalSupply = _totalSupply.sub(tokensToBurn);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(amount);

        emit Transfer(from, to, tokensToTransfer);
        emit Transfer(from, _pond, tokensToPond);
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
        uint256 ratePerTokenSubdivision = _saleRate.div(10**8);
        uint256 premiumPerTokenSubdivision = percVal(ratePerTokenSubdivision, _premium);
        uint256 premiumRate = ratePerTokenSubdivision.add(premiumPerTokenSubdivision);
        uint256 discountPerTokenSubdivision = percVal(premiumPerTokenSubdivision, _discount);
        uint256 discountRate = premiumRate.sub(discountPerTokenSubdivision);
        uint256 tokenAmount;
        if (weiAmount >= _minWeiForDiscount) {
            tokenAmount = weiAmount.div(discountRate);
        } else {
            tokenAmount = weiAmount.div(premiumRate);
        }

        require(beneficiary != address(0), "4LIFE: Buyer is address(0)");
        require(weiAmount > premiumRate, "4LIFE: WEI amount is to small");
        require(_balances[_pond] >= tokenAmount, "4LIFE: Not enough tokens in the Pond wallet");

        // Get token units to handle
        uint256 tokensToBurn = percVal(tokenAmount, _percent);
        uint256 tokensToPondMember = tokensToBurn;
        uint256 tokensToTransfer = tokenAmount.sub(tokensToBurn).sub(tokensToPondMember);

        // Get the Pond member to receive reward
        address pondMember;
        if (_totalPondMembers == 0) {
            pondMember = _pond;
        } else {
            _nounce += 1;
            uint256 random = uint256(keccak256(abi.encodePacked(_nounce, msg.sender, _highestDepositAddress))) % _totalPondMembers;
            pondMember = _PondID[random.add(1)];
        }

        // Update records for Highest deposit
        if (weiAmount > _highestDeposit) {
            emit NewHighestDeposit(_highestDepositAddress, beneficiary, _highestDeposit, weiAmount);
            _highestDeposit = weiAmount;
            _highestDepositAddress = beneficiary;
        }

        // Adjust balances
        if (pondMember == _pond) {
            uint256 substractFromPond = tokenAmount.sub(tokensToPondMember);
            _balances[_pond] = _balances[_pond].sub(substractFromPond);
            _balances[beneficiary] = _balances[beneficiary].add(tokensToTransfer);
            _totalSupply = _totalSupply.sub(tokensToBurn);
            emit Transfer(_pond, beneficiary, tokensToTransfer);
            emit Transfer(_pond, address(0), tokensToBurn);
        } else {
            _balances[_pond] = _balances[_pond].sub(tokenAmount);
            _balances[beneficiary] = _balances[beneficiary].add(tokensToTransfer);
            _balances[pondMember] = _balances[pondMember].add(tokensToPondMember);
            _totalSupply = _totalSupply.sub(tokensToBurn);
            emit Transfer(_pond, beneficiary, tokensToTransfer);
            emit Transfer(_pond, pondMember, tokensToPondMember);
            emit Transfer(_pond, address(0), tokensToBurn);
        }

        // Add user to Pond if needed
        if (weiAmount >= _minWeiForPondEntry) {
            // add the user to Pond
            if (_PondFamily[beneficiary] == 0) {
                // add beneficiary to Pond members count
                _totalPondMembers += 1;
                // add an ID to beneficiary
                _PondID[_totalPondMembers] = beneficiary;
                // add beneficiary to a Pond family
                if (weiAmount >= _minWeiForDiscount) {
                    // it's a Swan
                    _PondFamily[beneficiary] = 2;
                } else {
                    // it's a Duck
                    _PondFamily[beneficiary] = 1;
                }
            }
        }

        // Forward funds
        _pond.transfer(msg.value);
    }
}