pragma solidity ^0.8.0;

contract Log {
    struct Log{
        string ActionTo;
        string ActionFor;
        address TxOrigin;
        uint256 Timestamp;
        uint256 blockNum;
        address MsgSender;
    }
    Log[] logs;
    function addLog(string memory _actionTo,string memory _actionFor,address _msgSender) public {
        Log memory log=Log(_actionTo,_actionFor,tx.origin,block.timestamp,block.number,_msgSender);
        logs.push(log);
    }
    function getMyLog() public returns(Log[] memory){
        Log[] memory retLogs;
        uint j=0;
        for(uint i=0;i<logs.length;i++){
            if(logs[i].MsgSender==msg.sender){
                retLogs[j]=logs[i];
                j++;
            }
        }
        return retLogs;
    }
}