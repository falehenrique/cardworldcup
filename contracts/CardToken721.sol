pragma solidity ^0.4.21;

import "./ERC721.sol";

contract CardToken721 is ERC721 {
    
    // uint256 constant private MAX_UINT256 = 2**256 - 1;
    
    address public owner;
    string public name = "cardworldcup";
    string public symbol = "CWC";
    //O saldo total de tokens
    uint256 public totalSupply;

    //balanço da quanttidade de tokes de um usuário
    mapping(address => uint256) balances;
    //index dos cards com o valor do dono
    mapping (uint256 => Card) cardIndexToOwner;
    //relação dos donos com os cards
    mapping (address => Card[]) ownerShipTokens;
    //relações dos tokens aprovados a serem trocados de donos
    mapping(address => mapping (address => uint256)) allowed;

    //listas dos cards
    Card[] public cards;

    struct Card {
        uint256 id;
        bytes32 name;
        uint256 value;
        string infoIPFS;
        address addressOwner;
    }

    //evento que informa que novos cards foram criados pelo resp do contrato
    event LogMint(uint256 idCard);

    function CardToken721() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier existToken(uint256 _tokenId) {
        require(cardIndexToOwner[_tokenId].id > 0);
        _;
    }

    function implementsERC721() public pure returns (bool) {
        return true;
    }

    //retorna a quantidade de tokens de um endereço
    function balanceOf(address _owner) public view returns (uint256 balance) {
        require(_owner != address(0));
        return balances[_owner];
    }
    
    //retorna o endereço do dono do token
    function ownerOf(uint256 _tokenId) public view existToken(_tokenId) returns (address) {
        address ownerTokenId = cardIndexToOwner[_tokenId].addressOwner;
        
        assert(ownerTokenId != address(0x0));
        return ownerTokenId;
    }

    //permite que um endereço de token possa ser transferido para outro endereço
    function approve(address _to, uint256 _tokenId) public existToken(_tokenId) {
        require(msg.sender == ownerOf(_tokenId));
        require(msg.sender != _to);

        allowed[msg.sender][_to] = _tokenId;
        
        emit Approval(msg.sender, _to, _tokenId);
    }

    // alterar relação de donos
    function deleteTokenListMap(address _owner, uint256 _tokenId) private {
        for (uint256 i = 0; ownerShipTokens[_owner][i].id != _tokenId; i++) {
            delete ownerShipTokens[_owner][i];
        }
    }
    
    // alterar relação dos cards
    function changeOwnerTokenList(uint256 _tokenId, address _newOwnerToken) private {
        for (uint256 i = 0; cards[i].id != _tokenId; i++) {
            cards[i].addressOwner = _newOwnerToken;
        }
    }    

    //após liberação pela função approve agora o novo dono do token pode fazer posse do token
    function takeOwnership(uint256 _tokenId) public existToken(_tokenId) {
        address oldOwnerToken = ownerOf(_tokenId);
        assert(oldOwnerToken != address(0x0));
        require(allowed[oldOwnerToken][msg.sender] == _tokenId);
        _transfer(oldOwnerToken, msg.sender, _tokenId);
    }

    //transfere um token para outra endereço
    function transfer(address _to, uint256 _tokenId) public existToken(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);
    } 

    function _transfer(address _oldOwnerToken, address _newOwnerToken, uint256 _tokenId) internal {
        require(_oldOwnerToken != address(0));
        require(_newOwnerToken != address(0));
        require(ownerOf(_tokenId) == _oldOwnerToken);
        require(_oldOwnerToken != _newOwnerToken);
        
        balances[_oldOwnerToken] -= 1;
        
        deleteTokenListMap(_oldOwnerToken, _tokenId);
        changeOwnerTokenList(_tokenId, _newOwnerToken);
        
        cardIndexToOwner[_tokenId].addressOwner = _newOwnerToken;

        ownerShipTokens[_newOwnerToken].push(cardIndexToOwner[_tokenId]);
        
        balances[_newOwnerToken] += 1;
        emit Transfer(_oldOwnerToken, _newOwnerToken, _tokenId);
    }  
    
    //retorna o id do token de acordo com sua posição no array
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint tokenId) {
        return ownerShipTokens[_owner][_index].id;
    }    

    //retorna o endereço com informações(imagem, endereço de site, hashIPFS) do token
    function tokenMetadata(uint256 _tokenId) public view returns (string infoIPFS) {
        return cardIndexToOwner[_tokenId].infoIPFS;
    }
    
    function mint(Card _card) internal {
        require(cardIndexToOwner[_card.id].id == 0);
        
        cards.push(_card);
        
        totalSupply += 1;
        balances[msg.sender] += 1;          
        
        cardIndexToOwner[_card.id] = _card;
        
        ownerShipTokens[msg.sender].push(_card);

        emit LogMint(_card.id);
    }    
}