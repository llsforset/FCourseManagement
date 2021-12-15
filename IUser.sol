pragma solidity ^0.8.0;
interface IUser{
    function checkIfCanCheck(address _adrs) external returns(bool);
}