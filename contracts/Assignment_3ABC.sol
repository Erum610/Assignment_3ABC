// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


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
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Assignment_3ABC{
    
    uint public totalSupply;
    address private owner;
    address public approver; 
    uint public cappedLimit;
    uint public releaseTime= block.timestamp + 5 minutes;

    
    event approval(address indexed _owner, address indexed spender, uint numOfToken);
    event transfer(address indexed to, uint numOfToken);
    event Valuerecieved(address buyer, uint purchasedTokens);
    // string public constant name;
    // string public constant symbol;
    // uint public constant decimals;
    
    uint public tokenPrice = 1 ether;
    
    mapping(address => uint256 ) balance;
    mapping (address => mapping(address => uint256))allowed;
    
     modifier onlyOwner() {
        require (msg.sender == owner, "you are not the owner");
        _;
    }
    modifier delegatedOwner(){
        require(msg.sender == owner || msg.sender == approver);
        _;
    }
    
    constructor() {
        totalSupply = 10000;
        balance[msg.sender] = totalSupply;
        owner = msg.sender;
        cappedLimit = totalSupply*2;
    }
        
        function balanceOf(address account) public view returns(uint256){
            return balance[account];
        }   
        
       
        function Approval(address delegate, uint numOfToken) public onlyOwner returns(bool){
            allowed[msg.sender][delegate] = numOfToken;
            emit approval(msg.sender, delegate, numOfToken);
            return true;
        }
        
        function allowance(address tokenOwner, address delegate) public view returns(uint){
            return allowed[tokenOwner][delegate];
        }
        
        
    function buyToken()public payable returns(bool){
        uint tokenQty = msg.value/tokenPrice;
        require(msg.value>= tokenPrice);
        require(msg.sender != address(0), "Invalid buyer");
        balance[msg.sender] = balance[msg.sender] + tokenQty;
        balance[owner] = balance[owner] - tokenQty;
         emit Valuerecieved(msg.sender, msg.value);
        return true;
       
    }
    
     
     fallback() external payable{
        emit transfer(msg.sender, msg.value);
    }
    
    receive() external payable{
        buyToken();
    }
 
    function mintToken(address account, uint mintedToken) public onlyOwner {
        require(account != address(0), "Invalid address");
        require(mintedToken+ totalSupply <= cappedLimit);
        balance[account]= balance[account] +mintedToken;
        totalSupply = totalSupply + mintedToken;
        emit transfer( account, mintedToken);
        
    }
    
    function Transfer(address receiver, uint numOfToken) public returns(bool){
            require(numOfToken <= balance[msg.sender]);
            require (receiver != address(0), "Invalid address");
            require (block.timestamp >= releaseTime);
            balance[msg.sender] = balance[msg.sender] - numOfToken;
            balance[receiver] = balance[receiver] + numOfToken;
            emit transfer(receiver, numOfToken);
            return true;
        }
// 3C(1)
// 1. Owner can transfer the ownership of the Token Contract.
    function transferOwnership(address newOwner) public onlyOwner{
        require(newOwner != address(0), "Invalid Address");
        owner = newOwner;
    }
//   3C(2)
    // 2. Owner can approve or delegate anybody to manage the pricing of tokens.
    
    function setApprover(address delegatedAddress) external onlyOwner{
        require (delegatedAddress != address(0), "Invalid Address");
        approver = delegatedAddress;
    }
// 3C(3)
// 3. Update pricing method to allow owner and approver to change the price of the token
     function setPrice(uint newPrice) public delegatedOwner onlyOwner returns(uint){
        tokenPrice = newPrice;
        return (tokenPrice);
     }
//  3C(4)
//  3. Add the ability that Token Holder can return the Token and get back the Ether based on the current price.
    function returnToken(uint numOfToken) public payable returns(uint){
        require(numOfToken <= balance[msg.sender]);
        uint value = (numOfToken*tokenPrice);
        balance[msg.sender] = balance[msg.sender] - numOfToken;
        balance[owner] = balance[owner] + numOfToken;
        payable(msg.sender).transfer(value);
        emit transfer(owner, numOfToken);
        return value;
        
    }

}