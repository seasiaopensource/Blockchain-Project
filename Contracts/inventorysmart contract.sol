// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract InventoryContract {
    struct InventorySKU {
        bytes32 skuId;
        bytes32 productId;
        bytes32 allot_number;
        bytes32 name;
        bytes32 description;
        uint256 quantity;
        bytes32 stockedByName;
        bytes32 quantityAdjustment;
        bytes32 adjustmentMessage;
        bytes32 existingInventorySkuTransactionId;
    }

    struct AcceptInventorySKU {
        bytes32 skuId;
        bytes32 productId;
        bytes32 inventory_allot_number;
        bytes32 inventorySkuTransactionId;
        bytes32 name;
        bytes32 description;
        uint256 quantity;
        bytes32 acceptedByName;
        bytes32 acceptTransProp;
        bytes32 quantityAdjustment;
        bytes32 adjustmentMessage;
    }

    struct SaleSKU {
        bytes32 skuId;
        bytes32 productId;
        bytes32 inventorySkuTransactionId;
        uint256 quantity;
        bytes32 salesTransProp;
        bytes32 soldByName;
        bytes32 orderNumberId;
    }

    struct ResaleSKU {
        bytes32 skuId;
        bytes32 productId;
        bytes32 salesSkuTransactionId;
        uint256 quantity;
        bytes32 soldByName;
        bytes32 level4Use;
    }


    struct ReuseSKU {
        bytes32 skuId;
        bytes32 productId;
        bytes32 inventorySkuTransactionId;
        uint256 quantity;
        bytes32 reuseTransProp;
        bytes32 useByName;
        bytes32 docLink;
        bytes32 docHash;

    }

    struct RecycleSKU {
        bytes32 skuId;
        bytes32 productId;
        bytes32 inventorySkuTransactionId;
        uint256 quantity;
        bytes32 recycleTransProp;
        bytes32 useByName;
        bytes32 docLink;
        bytes32 docHash;
    }

    mapping(bytes32 => mapping(bytes32 => InventorySKU)) public inventorySkuItems;
    mapping(bytes32 => AcceptInventorySKU) public acceptedSkuItems;
    mapping(bytes32 => SaleSKU[]) public saleSkuItems;
    mapping(bytes32 => ResaleSKU[]) public resaleSkuItems;
    mapping(bytes32 => ReuseSKU[]) public reuseSkuItems;
    mapping(bytes32 => RecycleSKU[]) public recycleSkuItems;
    

    mapping(bytes32 => bytes32[]) public inventoryProductAllotNumbers;

    event AddInventory(
        address transactBy,
        string senderName,
        string skuId,
        string productId,
        uint256 quantity,
        uint256 timestamp
    );
    event ApproveInventory(
        address transactBy,
        string senderName,
        string skuId,
        string productId,
        string inventorySkuTransactionId,
        uint256 quantity,
        uint256 timestamp
    );
    event SaleInventory(
        address transactBy,
        string soldByName,
        string skuId,
        string productId,
        string inventorySkuTransactionId,
        string orderNumberId,
        uint256 quantity,
        uint256 timestamp
    );
    event ResaleInventory(
        address transactBy,
        string soldByName,
        string skuId,
        string productId,
        string salesSkuTransactionId,
        uint256 quantity,
        uint256 timestamp
    );

    event ReuseInventory(
        address transactBy,
        string useByName,
        string skuId,
        string productId,
        string inventorySkuTransactionId,
        uint256 quantity,
        uint256 timestamp,
        string transactionType

    );

    event RecycleInventory(
        address transactBy,
        string useByName,
        string skuId,
        string productId,
        string inventorySkuTransactionId,
        uint256 quantity,
        uint256 timestamp,
        string transactionType
    );

    function createInventory(
        string memory skuId,
        string memory productId,
        string memory allot_number,
        string memory name,
        string memory description,
        uint256 quantity,
        string memory senderName,
        string memory quantityAdjustment,
        string memory adjustmentMessage,
        string memory existingInventorySkuTransactionId
    ) public returns (bool) {
        inventorySkuItems[stringToBytes32(productId)][stringToBytes32(allot_number)] = InventorySKU(
            stringToBytes32(skuId),
            stringToBytes32(productId),
            stringToBytes32(allot_number),
            stringToBytes32(name),
            stringToBytes32(description),
            quantity,
            stringToBytes32(senderName),
            stringToBytes32(quantityAdjustment),
            stringToBytes32(adjustmentMessage),
            stringToBytes32(existingInventorySkuTransactionId)
        );


        inventoryProductAllotNumbers[stringToBytes32(productId)].push(stringToBytes32(allot_number));

        emit AddInventory(
            msg.sender,
            senderName,
            skuId,
            productId,
            quantity,
            block.timestamp
        );
        return true;
    }

    function updateInventory(
        string memory skuId,
        string memory productId,
        string memory inventory_allot_number,
        string memory inventorySkuTransactionId,
        string memory name,
        string memory description,
        uint256 quantity,
        string memory senderName,
        string memory acceptTransProp,
        string memory quantityAdjustment,
        string memory adjustmentMessage
    ) public returns (bool) {

        InventorySKU storage inventoryItem = inventorySkuItems[stringToBytes32(productId)][stringToBytes32(inventory_allot_number)];

        require(inventoryItem.quantity != 0, "Inventory not found for this allot number");
        
        if (inventoryItem.quantity >= quantity) {
            acceptedSkuItems[
                stringToBytes32(inventorySkuTransactionId)
            ] = AcceptInventorySKU(
                stringToBytes32(skuId),
                stringToBytes32(productId),
                stringToBytes32(inventory_allot_number),
                stringToBytes32(inventorySkuTransactionId),
                stringToBytes32(name),
                stringToBytes32(description),
                quantity,
                stringToBytes32(senderName),
                stringToBytes32(acceptTransProp),
                stringToBytes32(quantityAdjustment),
                stringToBytes32(adjustmentMessage)
            );

            emit ApproveInventory(
                msg.sender,
                senderName,
                skuId,
                productId,
                inventorySkuTransactionId,
                quantity,
                block.timestamp
            );
            return true;
        } else {
            revert("Quantity should be less than stocked inventory for this allot number");
        }
        
        
    }

    function saleInventorySku(
        string memory skuId,
        string memory productId,
        string memory inventorySkuTransactionId,
        uint256 quantity,
        string memory salesTransProp,
        string memory soldByName,
        string memory orderNumberId
    ) public returns (bool) {

        bool makeTransaction = canMakeTransaction(quantity, inventorySkuTransactionId);

        if (makeTransaction) {
            saleSkuItems[stringToBytes32(inventorySkuTransactionId)].push(
                SaleSKU(
                    stringToBytes32(skuId),
                    stringToBytes32(productId),
                    stringToBytes32(inventorySkuTransactionId),
                    quantity,
                    stringToBytes32(salesTransProp),
                    stringToBytes32(soldByName),
                    stringToBytes32(orderNumberId)
                )
            );
            emit SaleInventory(
                msg.sender,
                soldByName,
                skuId,
                productId,
                inventorySkuTransactionId,
                orderNumberId,
                quantity,
                block.timestamp
            );
            return true;
        } else {
          revert("Invalid quantity, can not make sale transaction");
        }
    }


    function reuseInventorySku(
        string memory skuId,
        string memory productId,
        string memory inventorySkuTransactionId,
        uint256 quantity,
        string memory reuseTransProp,
        string memory useByName,
        string memory docLink,
        string memory docHash
    ) public returns (bool) {

        bool makeTransaction = canMakeTransaction(quantity, inventorySkuTransactionId);

        if (makeTransaction) {
            reuseSkuItems[stringToBytes32(inventorySkuTransactionId)].push(
                ReuseSKU(
                    stringToBytes32(skuId),
                    stringToBytes32(productId),
                    stringToBytes32(inventorySkuTransactionId),
                    quantity,
                    stringToBytes32(reuseTransProp),
                    stringToBytes32(useByName),
                    stringToBytes32(docLink),
                    stringToBytes32(docHash)
                )
            );
           
            emit ReuseInventory(
                msg.sender,
                useByName,
                skuId,
                productId,
                inventorySkuTransactionId,
                quantity,
                block.timestamp,
                "reuse_inventory"
            );
            return true;
        } else {
          revert("Invalid quantity, can not make reuse transaction");
        }

    }


    function recycleInventorySku(
        string memory skuId,
        string memory productId,
        string memory inventorySkuTransactionId,
        uint256 quantity,
        string memory recycleTransProp,
        string memory useByName,
        string memory docLink,
        string memory docHash
    ) public returns (bool) {

        bool makeTransaction = canMakeTransaction(quantity, inventorySkuTransactionId);

        if (makeTransaction) {
            recycleSkuItems[stringToBytes32(inventorySkuTransactionId)].push(
                RecycleSKU(
                    stringToBytes32(skuId),
                    stringToBytes32(productId),
                    stringToBytes32(inventorySkuTransactionId),
                    quantity,
                    stringToBytes32(recycleTransProp),
                    stringToBytes32(useByName),
                    stringToBytes32(docLink),
                    stringToBytes32(docHash)
                )
            );
           
            emit RecycleInventory(
                msg.sender,
                useByName,
                skuId,
                productId,
                inventorySkuTransactionId,
                quantity,
                block.timestamp,
                "recycle_inventory"
            );
            return true;
        } else {
          revert("Invalid quantity, can not make recycle transaction");
        }
    }

    function resaleSoldSku(
        string memory skuId,
        string memory productId,
        string memory inventorySkuTransactionId,
        string memory salesSkuTransactionId,
        string memory orderNumberId,
        uint256 quantity,
        string memory soldByName,
        string memory level4Use
    ) public returns (bool) {
        SaleSKU[] memory saleItems = saleSkuItems[
            stringToBytes32(inventorySkuTransactionId)
        ];

        if (saleItems.length > 0) {
            uint256 saleSkuQuantity = 0;
            uint256 totalResaleSkuQuantity = quantity;

            for (uint256 i = 0; i < saleItems.length; i++) {
                if (
                    saleItems[i].orderNumberId == stringToBytes32(orderNumberId)
                ) {
                    saleSkuQuantity += saleItems[i].quantity;
                }
            }

            ResaleSKU[] memory resaleItems = resaleSkuItems[
                stringToBytes32(salesSkuTransactionId)
            ];

            if (resaleItems.length > 0) {
                for (uint256 i = 0; i < resaleItems.length; i++) {
                    totalResaleSkuQuantity += resaleItems[i].quantity;
                }
            }

            if (saleSkuQuantity > totalResaleSkuQuantity) {
                saveResaleSku(
                    skuId,
                    productId,
                    salesSkuTransactionId,
                    soldByName,
                    level4Use,
                    quantity
                );

                return true;
            }
        }
        return false;
    }

    function saveResaleSku(
        string memory skuId,
        string memory productId,
        string memory salesSkuTransactionId,
        string memory soldByName,
        string memory level4Use,
        uint256 quantity
    ) internal {
        bytes32 sku = stringToBytes32(skuId);
        bytes32 product = stringToBytes32(productId);
        bytes32 salesSku = stringToBytes32(salesSkuTransactionId);
        bytes32 soldBy = stringToBytes32(soldByName);
        bytes32 level4 = stringToBytes32(level4Use);

        resaleSkuItems[salesSku].push(
            ResaleSKU(sku, product, salesSku, quantity, soldBy, level4)
        );

        emit ResaleInventory(
            msg.sender,
            soldByName,
            skuId,
            productId,
            salesSkuTransactionId,
            quantity,
            block.timestamp
        );
    }


    function canMakeTransaction(uint256 quantity, string memory inventorySkuTransactionId) internal returns (bool) {

        AcceptInventorySKU storage acceptedItems = acceptedSkuItems[
            stringToBytes32(inventorySkuTransactionId)
        ];

        uint256 acceptedQuantity = 0;
        
        if (acceptedItems.quantity > 0) {
            acceptedQuantity = acceptedItems.quantity;
        }

        uint256 totalQuantity = quantity;

        if (acceptedQuantity > 0) {
            
            SaleSKU[] memory saleItems = saleSkuItems[
                stringToBytes32(inventorySkuTransactionId)
            ];

            ReuseSKU[] memory reuseItems = reuseSkuItems[
                stringToBytes32(inventorySkuTransactionId)
            ];

            RecycleSKU[] memory recycleItems = recycleSkuItems[
                stringToBytes32(inventorySkuTransactionId)
            ];

            if (saleItems.length > 0) {
                for (uint256 i = 0; i < saleItems.length; i++) {
                    totalQuantity += saleItems[i].quantity;
                }
            }

            if (reuseItems.length > 0) {
                for (uint256 i = 0; i < reuseItems.length; i++) {
                    totalQuantity += reuseItems[i].quantity;
                }
            }

            if (recycleItems.length > 0) {
                for (uint256 i = 0; i < recycleItems.length; i++) {
                    totalQuantity += recycleItems[i].quantity;
                }
            }

        }

        return acceptedQuantity > totalQuantity;
    }

    function getAllInventorySKU(string memory productId)
        public
        view
        returns (InventorySKU[] memory inventoryItems)
    {
        uint256 mappingCollectionLength = inventoryProductAllotNumbers[
            stringToBytes32(productId)
        ].length;

        InventorySKU[] memory ret = new InventorySKU[](mappingCollectionLength);

        for (uint256 i = 0; i < mappingCollectionLength; i++) {
            bytes32 allot_number = inventoryProductAllotNumbers[stringToBytes32(productId)][i];
            ret[i] = inventorySkuItems[stringToBytes32(productId)][allot_number];
        }

        return ret;
    }

    function getAllSaleSKU(string memory inventorySkuTransactionId)
        public
        view
        returns (SaleSKU[] memory saleItems)
    {
        uint256 mappingCollectionLength = saleSkuItems[
            stringToBytes32(inventorySkuTransactionId)
        ].length;

        SaleSKU[] memory ret = new SaleSKU[](mappingCollectionLength);

        for (uint256 i = 0; i < mappingCollectionLength; i++) {
            ret[i] = saleSkuItems[stringToBytes32(inventorySkuTransactionId)][
                i
            ];
        }

        return ret;
    }

    function getAllResaleSKU(string memory salesSkuTransactionId)
        public
        view
        returns (ResaleSKU[] memory resaleItems)
    {
        uint256 mappingCollectionLength = resaleSkuItems[
            stringToBytes32(salesSkuTransactionId)
        ].length;

        ResaleSKU[] memory ret = new ResaleSKU[](mappingCollectionLength);

        for (uint256 i = 0; i < mappingCollectionLength; i++) {
            ret[i] = resaleSkuItems[stringToBytes32(salesSkuTransactionId)][i];
        }

        return ret;
    }


    function getAllReuseSKU(string memory inventorySkuTransactionId)
        public
        view
        returns (ReuseSKU[] memory reuseItems)
    {
        uint256 mappingCollectionLength = reuseSkuItems[
            stringToBytes32(inventorySkuTransactionId)
        ].length;

        ReuseSKU[] memory ret = new ReuseSKU[](mappingCollectionLength);

        for (uint256 i = 0; i < mappingCollectionLength; i++) {
            ret[i] = reuseSkuItems[stringToBytes32(inventorySkuTransactionId)][
                i
            ];
        }

        return ret;
    }


    function getAllRecycleSKU(string memory inventorySkuTransactionId)
        public
        view
        returns (RecycleSKU[] memory recycleItems)
    {
        uint256 mappingCollectionLength = recycleSkuItems[
            stringToBytes32(inventorySkuTransactionId)
        ].length;

        RecycleSKU[] memory ret = new RecycleSKU[](mappingCollectionLength);

        for (uint256 i = 0; i < mappingCollectionLength; i++) {
            ret[i] = recycleSkuItems[stringToBytes32(inventorySkuTransactionId)][
                i
            ];
        }

        return ret;
    }

    function stringToBytes32(string memory source)
        public
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}
