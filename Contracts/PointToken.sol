// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

/**
The issue is that the JavaScript VM or local or private network or testnet doesn’t have the ERC1820 registry deployed. You would need to deploy the ERC1820 registry first if deploying this contract to a JavaScript VM



use deployed contract address which is currently 0x9a3DBCa554e9f6b9257aAa24010DA8377C57c17e addres in ERC777 contract in node modules for line mentioned below

IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x9a3DBCa554e9f6b9257aAa24010DA8377C57c17e);

By default EIP-1820 Registry Contract Address 0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24 is the same on each every public chain on which it is deployed as the same transaction is used to deploy.

["0x1000000000000000000000000000000000000000","0x1000000000000000000000000000000000000000","0x1000000000000000000000000000000000000000","0x1000000000000000000000000000000000000000"]

*/

import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC777/ERC777.sol";

contract PointToken is ERC777, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    address owner;

    uint256 defaultInitialSupply =  100000;
    uint256 divisiblity = (10 ** 18); 

    
    constructor(string memory name, string memory symbol, uint256 initialSupply, address[] memory defaultAddress) public ERC777(name, symbol, defaultAddress) {
        
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);

        owner = msg.sender;

        if (initialSupply == 0) {
            initialSupply = defaultInitialSupply;
        }

        addPoints(owner, initialSupply, "", "");
    }

    function mintToken(
        address to,
        uint256 amount,
        string memory userData,
        string memory operatorData
    ) public {
        require(hasRole(MINTER_ROLE, msg.sender), "PointToken: Caller is not a minter");
        _mint(to, amount * divisiblity, bytes(userData), bytes(operatorData));
        approve(to, owner, amount * divisiblity);
    }

    function burnToken(uint256 amount, bytes memory data) public {
        require(hasRole(BURNER_ROLE, msg.sender), "PointToken: Caller is not a burner");
        burn(amount, data);
    }

    function addPoints(
        address to,
        uint256 amount,
        string memory userData,
        string memory operatorData
    ) public {
        require(hasRole(MINTER_ROLE, msg.sender), "PointToken: Caller is not a minter");
        require(to != address(0), "PointToken: add to the zero address");
        require(amount > 0, "PointToken: Invalid amount");
        mintToken(to, amount, userData, operatorData);
    }

    function approve(address holder, address spender, uint256 value) private returns (bool) {
        _approve(holder, spender, value);
        return true;
    }

    function subtractPoints(address tokenHolder, uint256 amount, string memory data)
        public
        returns (bool)
    {
        require(tokenHolder != address(0), "PointToken: get from the zero address");
        require(hasRole(BURNER_ROLE, msg.sender), "PointToken: Caller is not a burner");
        require(amount > 0, "PointToken: Invalid amount");
        require(balanceOf(tokenHolder) >= amount, "Can't subtract points, amount provided is less than holdings.");

        if (tokenHolder != msg.sender) {
            transferFrom(tokenHolder, msg.sender, amount);
        }
        
        
        burnToken(amount, bytes(data));
    }

    function getPoints(address pointOwner) public view returns (uint256) {
        require(pointOwner != address(0), "PointToken: get from the zero address");
        return balanceOf(pointOwner) / divisiblity;
    }


    
}
