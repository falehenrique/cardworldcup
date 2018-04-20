pragma solidity ^0.4.21;

import "./CardToken721.sol";

contract CardWorldCup is CardToken721 {
    //event LogNewCard(uint _id, string _name);
    //event LogCardCreated(bool _created);

    function CardWorldCup() public {
        
    }

    function _createCard(string _name, string _infoIPFS) public onlyOwner {
        bytes32 name = keccak256(_name);
        uint64 _id = (uint64) (cards.length + 1);
        Card memory card = Card({id: _id, name: name, value: 0, infoIPFS:_infoIPFS ,addressOwner: msg.sender});
        mint(card);
    } 
    
}