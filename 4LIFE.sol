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
     address public owner;
     
     event OwnershipTransferred(address _from, address _to);
     
     /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
     constructor() public {
         owner = msg.sender;
         emit OwnershipTransferred(address(0), msg.sender);
     }
     
     /**
     * @dev Throws if called by any account other than the owner.
     */
     modifier onlyOwner() {
         require(msg.sender == owner, "Ownable: caller is not the owner");
         _;
     }
     
     /**
     * @dev Returns true if the caller is the current owner.
     */
     function isOwner() public view returns (bool) {
         return msg.sender == owner;
     }
     
     /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
     function TransferOwnership(address _newOwner) external onlyOwner {
         require(_newOwner != address(0), "Ownable: new owner is the zero address");
         emit OwnershipTransferred(owner, _newOwner);
         owner = _newOwner;
     }
 }
