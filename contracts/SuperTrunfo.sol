pragma solidity 0.4.18;

import "./ERC721.sol";

contract SuperTrunfo is ERC721 {
    string public name = "SuperTrunfo";
    string public symbol = "ST";
    uint powerDigits = 2;
    uint power = 18 ** powerDigits;
    event LogNewCard(uint _id, string _name, uint _power);

    //aprovadores por cards
    mapping (uint256 => address) public cardIndexToApproved;
    //index dos cards com o valor do dono
    mapping (uint256 => address) public cardIndexToOwner;    
    //relação dos donos com os cards
    mapping (address => uint256) ownerShipTokenCount;
    //listas dos cards
    Card[] public cards;
    //relação do id do card com o objeto
    mapping(uint256 => Card) public cardsById;

    struct Card {
        uint256 id;
        string name;
        uint power;
    }

    function _createCard(string _name, uint _power) private returns(uint256) {
        uint256 _id = cards.length + 1;
        Card memory card = Card({id: _id, name: _name, power: _power});
        cards.push(card);
        cardsById[_id] = card;
        LogNewCard(_id, _name, _power);
        return _id;
    } 

    function _generateRandomPower(string _str) private view returns (uint) {
        uint rand = uint(keccak256(_str));
        return rand % powerDigits;
    }

    function createRandomTrumfo(string _name) public {
        uint randPower = _generateRandomPower(_name);
        uint256 idCard = _createCard(_name, randPower);

        ownerShipTokenCount[msg.sender] = idCard;
        cardIndexToOwner[idCard] = msg.sender;
    }

    function implementsERC721() public pure returns (bool)
    {
        return true;
    }

    function totalSupply() public view returns (uint) {
        return cards.length;
    }

    //returns the number of cards owned by a specific address.
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownerShipTokenCount[_owner];
    }    

    //ERC-721.
    function ownerOf(uint256 _tokenId)
        public
        view
        returns (address owner)
    {
        owner = cardIndexToOwner[_tokenId];

        require(owner != address(0));
    }

    //ERC-721
    function approve(
        address _to,
        uint256 _tokenId
    )
        public
    {
        require(_owns(msg.sender, _tokenId));

        _approve(_tokenId, _to);
        Approval(msg.sender, _to, _tokenId);
    }

    function _approve(uint256 _tokenId, address _approved) internal {
        cardIndexToApproved[_tokenId] = _approved;
    }

    //ERC-721.
    function transfer(
        address _to,
        uint256 _tokenId
    )
        public
    {
        require(_to != address(0));
        require(_owns(msg.sender, _tokenId));
        _transfer(msg.sender, _to, _tokenId);
    }

    //ERC-721.
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
    {
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        _transfer(_from, _to, _tokenId);
    }

    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return cardIndexToApproved[_tokenId] == _claimant;
    }

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return cardIndexToOwner[_tokenId] == _claimant;
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownerShipTokenCount[_to]++;
        cardIndexToOwner[_tokenId] = _to;
        if (_from != address(0)) {
            ownerShipTokenCount[_from]--;
        }
        Transfer(_from, _to, _tokenId);
    }  
}
