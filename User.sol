pragma solidity ^0.8.0;

contract User {
    enum Identity { guest,student,teacher }
    enum Authority { admin,superAdmin,notAdmin }
    struct User{
        address UserAds;
        string Name;
        uint256 StuNo;
        uint256 Grade;
        bytes32 NameNoHash;
        Authority authority;
        Identity identity;
    }
    address superAdmin;
    address[] allUsers;
    address[] allAdmins;
    mapping(address=>User) users;
    constructor(){
        superAdmin=msg.sender;
        initiateSuperAdmin();
    }
    modifier checkSuperAdminAuthority(){
        require(msg.sender==superAdmin);
        _;
    }
    modifier checkAdminAuthority(){
        require(checkIfExist(msg.sender,allAdmins));
        _;
    }
    modifier updateAllUsers(){
        _;
        allUsers.push(msg.sender);
    }
    modifier updateAllAdmins(address _adrs){
        _;
        allAdmins.push(_adrs);
    }
    function modifyMyInfo(string memory _name,uint256 _stuNo,uint256 _grade,Identity _identity) public returns(User memory){
        users[msg.sender].Name=_name;
        users[msg.sender].StuNo=_stuNo;
        users[msg.sender].Grade=_grade;
        users[msg.sender].NameNoHash=keccak256(abi.encode(_stuNo,_name));
        return users[msg.sender];
    }
    function initiateUser() updateAllUsers() public returns(User memory){
        require(checkIfExist(msg.sender,allUsers),"already have this user Address");
        User memory user=User(msg.sender,"",0,0,bytes32(0),Authority.notAdmin,Identity.guest);
        users[msg.sender]=user;
        return user;
    }
    function initiateSuperAdmin() updateAllUsers() updateAllAdmins(msg.sender) private returns(User memory){
        User memory user=User(msg.sender,"",0,0,bytes32(0),Authority.superAdmin,Identity.guest);
        users[msg.sender]=user;
        return user;
    }
    function upUserToAdmin(address userAdrs) checkAdminAuthority() updateAllAdmins(userAdrs) public {
        require(userAdrs!=superAdmin,"superAdmin CANNOT abadon");
        users[userAdrs].authority=Authority.admin;
    }
    // function downAdminToUser(address userAdrs) checkSuperAdminAuthority() public{
    //     require(userAdrs!=superAdmin,"superAdmin CANNOT abadon");
    //     users[userAdrs].authority=Authority.notAdmin;
    // }
    function getAllUsers() public returns(address[] memory){
        return allUsers;
    }
    function getAllAdmins() public returns(address[] memory){
        return allAdmins;
    }
    function getUserInfo(address userAdrs) public returns(User memory){
        return users[userAdrs];
    }
    function getMyInfo() public returns(User memory){
        return getUserInfo(msg.sender);
    }
    function checkIfExist(address adrs, address[] memory adrss) public returns (bool){
        for (uint i = 0; i < adrss.length; i++) {
            if (adrss[i] == adrs) {
                return true;
            }
        }
        return false;
    }

}