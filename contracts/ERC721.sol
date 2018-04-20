pragma solidity ^0.4.21;

contract ERC721 {
    // ERC20 compatible functions
    //function name() public view returns (string _name);
    //function symbol() public view returns (string _symbol);
    //function totalSupply() public view returns (uint256 _totalSupply);
    function balanceOf(address _owner) public view returns (uint _balance);
    // Functions that define ownership
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function approve(address _to, uint256 _tokenId) public;
    function takeOwnership(uint256 _tokenId) public;
    function transfer(address _to, uint256 _tokenId) public;
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint _tokenId);
    // Token metadata
    function tokenMetadata(uint256 _tokenId) public view returns (string _infoUrl);
    // Events
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
}