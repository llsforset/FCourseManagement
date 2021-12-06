pragma solidity ^0.8.0;
interface ILog{
    function addLog(string memory _actionTo,string memory _actionFor,address _msgSender,uint256 _id,bool _ifSuccess) external;
    function addLog_User(string memory _actionTo,string memory _actionFor,address _msgSender,string memory _name,bool _ifSuccess) external;
}