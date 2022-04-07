// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

contract SalePoint is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _pointIDs;

    address private authorized;

    struct Point {
        bytes32 orderID;
        bytes32 soldToUserID;
        bytes32 soldToEmail;
        address owner;
        uint256 C;
        uint256 W;
        uint256 CH;
        uint256 WA;
        bytes32 Ckg;
        bytes32 Wkg;
        bytes32 CHkg;
        bytes32 WAkg;
    }

    mapping(uint256 => Point) public points;

    constructor() ERC721("Point", "SLP") {
        authorized = msg.sender;
    }

    modifier onlyAuthorized() {
        require(
            msg.sender == authorized,
            "Only Authorized person can create new point"
        );

        _;
    }

    function createPoint(Point memory point, string memory pointURI)
        public
        onlyAuthorized
        returns (uint256 pointID)
    {
        _pointIDs.increment();

        pointID = _pointIDs.current();

        points[pointID] = point;

        _safeMint(point.owner, pointID);

        _setTokenURI(pointID, pointURI);
    }

    function getPoint(uint256 _pointID)
        public
        view
        returns (Point memory point, string memory pointURI)
    {
        require(points[_pointID].owner != address(0), "Point does not exist");

        point = points[_pointID];
        pointURI = super.tokenURI(_pointID);
    }

    function updatePoint(
        Point memory point,
        uint256 _pointID,
        address owner,
        string memory pointURI
    ) public returns (bool updated) {
        address pointOwner = points[_pointID].owner;

        require(pointOwner != address(0), "Point does not exist");

        if (pointOwner != authorized || pointOwner != owner) {
            revert("You are not authorized.");
        } else {
            points[_pointID] = point;
            _setTokenURI(_pointID, string(abi.encodePacked(pointURI)));
            updated = true;
        }
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
