// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * The Passport contract does this and that...
 */
contract Passport is ERC721, Ownable {
  address payable public _owner;
  address payable public _cabindao = payable(0x8dca852d10c3CfccB88584281eC1Ef2d335253Fd);
  mapping(uint256 => bool) public sold;
  uint256 public price;
  uint256 public supply;
  uint256[] public tokenIds;
  string public metadataHash;
  bool private enableTransfer = false;
  uint256 public royalty;
  event Purchase(address owner, uint256 price, uint256 id, string uri);
  constructor(address owner, string memory name_, string memory symbol_, uint256 _supply, uint256 _price, string memory _metadataHash, uint256 _royalty) ERC721(name_, symbol_) {
    _owner = payable(owner);
    price = _price;
    supply = _supply;
    metadataHash = _metadataHash;
    royalty = _royalty;
  }

  function buy(uint256 _id) external payable {
    require(supply > 0, "Error, no more supply of this membership");
    require(msg.value >= price, "Error, Token costs more");
    require(!sold[_id], "Error, Token is sold");

    uint256 ownerPayment = msg.value * 39 / 40;
    (bool success1, ) = _owner.call{value: ownerPayment}("");
    require(success1, "Address: unable to send value, recipient may have reverted");

    uint256 cabinPayment = msg.value / 40;
    (bool success2, ) = _cabindao.call{value: cabinPayment}("");
    require(success2, "Address: unable to send value, recipient may have reverted");
    
    _mint(msg.sender, _id);
    sold[_id] = true;
    supply = supply - 1;
    
    emit Purchase(msg.sender, price, _id, tokenURI(_id));
  }

  function transfer(
      address from,
      address to,
      uint256 tokenId
  ) external payable {
    enableTransfer = true;
    if (royalty > 0) {
      uint256 ownerPayment = royalty * 39 / 40;
      (bool success1, ) = _owner.call{value: ownerPayment}("");
      require(success1, "Address: unable to send value, recipient may have reverted");

      uint256 cabinPayment = royalty / 40;
      (bool success2, ) = _cabindao.call{value: cabinPayment}("");
      require(success2, "Address: unable to send value, recipient may have reverted");
    }
    _transfer(from, to, tokenId);
    enableTransfer = false;
  }

  function _transfer(
      address from,
      address to,
      uint256 tokenId
  ) internal virtual override {
    require(enableTransfer, "Token transfer disabled");
    super._transfer(from, to, tokenId);
  }

  function get() public view returns(string memory, string memory, uint256, uint256, string memory) {
    return (name(), symbol(), supply, price, metadataHash);
  }

  event Received(address, uint);
  receive() external payable {
      emit Received(msg.sender, msg.value);
  }
}
