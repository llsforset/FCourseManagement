/// @title Experiment -- Experiment Management
/// @author BloodMoon - <nerbonic@gmail.com>
/// @author 5579 -<1025714986@qq.com>
/// @version 0.1
/// @date 2021-12-3
import "./ILog.sol";
import "./IUser.sol";
pragma solidity ^0.8.0;

contract Experiment {
    enum Check {NotCheck,RefuseCheck,PastCheck,Delete}//1215
    struct Experiment {
        uint256 Id;
        string Name;
        address Author;
        string Tag;
        Check Status;
        address[] Operators;

        string Class;
        string Description;
        uint256 Time;
        uint256 BlockNum;
        string[] CheckComments;//1215
        address[] Checker;//1215
    }

    struct File {
        string Path;
        bool enable;
    }

    ILog iLog;
    IUser iUser;   //1215
    mapping(uint256 => string[]) Filenames;
    mapping(uint256 => mapping(string => File)) Files;
    mapping(uint256 => address[]) arrayScores;
    mapping(uint256 => mapping(address => uint256)) Scores;
    Experiment[] experiments;
    constructor(address _logAddress,address _userAddress){
        iLog = ILog(_logAddress);
        iUser=IUser(_userAddress);//1215
    }
    //1215
    function checkExperiment(uint256 _id,Check result,string memory checkComment) public returns(bool){
        require(iUser.checkIfCanCheck(msg.sender));
        experiments[_id].Status=result;
        experiments[_id].CheckComments.push(checkComment);
        experiments[_id].Checker.push(msg.sender);
        iLog.addLog("Experiment", "checkExperiment", msg.sender, _id, true);
        return true;

    }
    //1215
    function getNotCheck() public view returns(Experiment[] memory){
        uint length = experiments.length;
        uint sum = 0;
        for (uint i = 0; i < length; i++) {
            if (experiments[i].Status == Check.NotCheck) {
                sum++;
            }
        }
        Experiment[] memory myExperiments = new Experiment[](sum);
        uint j = 0;
        for (uint i = 0; i < length; i++) {
            if (experiments[i].Status == Check.NotCheck) {
                myExperiments[j] = experiments[i];
                j++;
            }
        }
        return myExperiments;
    }
    //1215
    function checkBatch(uint256[] memory _ids,Check[] memory _results,string[] memory _comments) public returns(bool){
        uint length=_ids.length;
        for(uint i=0;i<length;i++){
            checkExperiment(_ids[i],_results[i],_comments[i]);
        }
        return true;

    }
    //1215
    function addExperimentInfoWithUpload(string memory _name, string memory _tag, string memory _class, string memory _description,string[] memory _filename,string[] memory _filepath) public returns (Experiment memory){
        require(!checkIfMyExperimentNameExist(_name), "name exist");
        uint256 nextid = experiments.length;
        Experiment memory experiment = Experiment({
        Id : nextid,
        Name : _name,
        Author : msg.sender,
        Tag : _tag,
        Status : Check.NotCheck,
        Operators : new address[](0),
        Checker:new address[](0),
        CheckComments:new string[](0),
        Class : _class,
        Description : _description,
        Time : block.timestamp,
        BlockNum : block.number}
        );
        experiments.push(experiment);
        for(uint i=0;i<_filename.length;i++){
            addExperimentUpload(nextid, _filepath[i], _filename[i]);
        }

        iLog.addLog("Experiment", "addExperimentInfoWithUpload", msg.sender, nextid, true);
        return experiment;
    }
    //??????????????????????????????????????????????????????????????????
    modifier checkAuthority(uint256 _id){
        address author = experiments[_id].Author;
        require(msg.sender == author || checkIfAuthority(experiments[_id].Operators), "not authority");
        _;
    }
    //????????????????????????
    function addExperimentInfo(string memory _name, string memory _tag, string memory _class, string memory _description) public returns (Experiment memory){
        require(!checkIfMyExperimentNameExist(_name), "name exist");
        uint256 nextid = experiments.length;
        Experiment memory experiment = Experiment({
        Id : nextid,
        Name : _name,
        Author : msg.sender,
        Tag : _tag,
        Status : Check.NotCheck,
        Operators : new address[](0),
        Checker:new address[](0),
        CheckComments:new string[](0),
        Class : _class,
        Description : _description,
        Time : block.timestamp,
        BlockNum : block.number}
        );
        experiments.push(experiment);
        iLog.addLog("Experiment", "addExperimentInfo", msg.sender, nextid, true);
        return experiment;
    }
    //????????????????????????????????????
    function checkIfMyExperimentNameExist(string memory _name) public returns (bool){
        uint length = experiments.length;
        for (uint i = 0; i < length; i++) {
            if (experiments[i].Author == msg.sender && hashCompareInternal(_name, experiments[i].Name)) {
                return true;
            }
        }
        return false;
    }
    //????????????????????????
    function getExperimentInfo(uint256 _id) public view returns (Experiment memory){
        Experiment memory retExperiment = experiments[_id];
        return retExperiment;
    }
    //????????????????????????
    function modifyExperimentInfo(uint256 _id, string memory _name, string memory _tag, string memory _class, string memory _description)
    public checkAuthority(_id) returns (Experiment memory){

        address author = experiments[_id].Author;

        experiments[_id].Name = _name;

        experiments[_id].Tag = _tag;
        //????????????true???false??????????????????????????????
        experiments[_id].Class = _class;
        experiments[_id].Description = _description;
        experiments[_id].Time = block.timestamp;

        iLog.addLog("Experiment", "modifyExperimentInfo", msg.sender, _id, true);
        return experiments[_id];


    }
    //??????????????????
    function disableExperiment(uint256 _id) public returns (bool){
        experiments[_id].Status = Check.Delete;
        iLog.addLog("Experiment", "disableExperiment", msg.sender, _id, true);
        return true;
    }
    //string???????????????
    function hashCompareInternal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
    //???????????????????????????????????????????????????
    function checkIfAuthority(address[] memory _operators) private returns (bool){
        for (uint i = 0; i < _operators.length; i++) {
            if (_operators[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }
    //?????????????????????????????????
    function getExperimentUploadInfo(uint256 _id) public view returns (string[] memory, string[] memory){
        string[] memory names = Filenames[_id];
        uint sum = 0;
        for (uint i = 0; i < names.length; i++) {
            string memory filename = names[i];
            if (Files[_id][filename].enable) {
                sum++;
            }
        }
        string[] memory paths = new string[](sum);
        uint j = 0;
        for (uint i = 0; i < names.length; i++) {
            string memory filename = names[i];
            if (Files[_id][filename].enable) {
                paths[j] = Files[_id][filename].Path;
                j++;
            }
        }
        return (paths, names);
    }
    //???????????????????????????
    function addExperimentUpload(uint256 _id, string memory _filepath, string memory _filename) checkAuthority(_id) public returns (bool){
        if (checkIfExist(_filename, Filenames[_id])) {return false;}
        else {
            Filenames[_id].push(_filename);
            File memory file = File({Path : _filepath, enable : true});
            Files[_id][_filename] = file;
            iLog.addLog("Experiment", "addExperimentUpload", msg.sender, _id, true);
            return true;
        }

    }

    function checkUploadIfExist(uint256 _id, string memory _filename) public returns (bool){
        return !checkIfExist(_filename, Filenames[_id]);
    }
    //???????????????????????????
    function modifyExperimentUpload(uint256 _id, string memory _filepath, string memory _filename) checkAuthority(_id) public returns (bool){
        Files[_id][_filename].Path = _filepath;
        iLog.addLog("Experiment", strConcat("modifyExperimentUpload", _filepath), msg.sender, _id, true);
        return true;
    }
    //???????????????????????????
    function deleteExperimentUpload(uint256 _id, string memory _filename) checkAuthority(_id) public returns (bool){
        Files[_id][_filename].enable = false;
        iLog.addLog("Experiment", "deleteExperimentUpload", msg.sender, _id, true);
        return true;
    }
    //????????????????????????
    function enableExperimentUpload(uint256 _id, string memory _filename) checkAuthority(_id) public returns (bool){
        Files[_id][_filename].enable = true;
        iLog.addLog("Experiment", "enableExperimentUpload", msg.sender, _id, true);
        return true;
    }
    //????????????????????????
    function getExperimentUpload(uint256 _id, string memory _filename) public view returns (bool){
        return Files[_id][_filename].enable;
    }
    //??????operator
    function addOperator(uint256 _id, address _newOperator) checkAuthority(_id) public returns (bool){
        if (!checkIfExist(_newOperator, experiments[_id].Operators)) {
            experiments[_id].Operators.push(_newOperator);
            iLog.addLog("Experiment", strConcat("addOperatorSucceed", toString(_newOperator)), msg.sender, _id, true);
            return true;
        }
        iLog.addLog("Experiment", strConcat("addOperatorFail", toString(_newOperator)), msg.sender, _id, true);
        return false;

    }
    //????????????1
    function checkIfExist(address adrs, address[] memory adrss) public returns (bool){
        for (uint i = 0; i < adrss.length; i++) {
            if (adrss[i] == adrs) {
                return true;
            }
        }
        return false;
    }
    //????????????2
    function checkIfExist(string memory adrs, string[] memory adrss) public returns (bool){
        for (uint i = 0; i < adrss.length; i++) {
            if (hashCompareInternal(adrss[i], adrs)) {
                return true;
            }
        }
        return false;
    }
    //??????
    function addScore(uint256 _id, uint256 score) public returns (uint256){
        require(score <= 100 && score >= 0, "score overflow");
        if (checkIfExist(msg.sender, arrayScores[_id])) {
            Scores[_id][msg.sender] = score;
        } else {
            Scores[_id][msg.sender] = score;
            arrayScores[_id].push(msg.sender);
        }

        iLog.addLog("Experiment", strConcat("addScore:", toString(score)), msg.sender, _id, true);
        return score;
    }
    //???????????????
    function calculateScore(uint256 _id) public view returns (uint256){
        uint256 sum = 0;
        uint256 length = arrayScores[_id].length;
        for (uint i = 0; i < length; i++) {
            uint256 score = Scores[_id][arrayScores[_id][i]];
            sum = sum + score;
        }
        return sum / length;
    }


    function getAllMyExperimentInfo() public view returns (Experiment[] memory){

        uint length = experiments.length;
        uint sum = 0;
        for (uint i = 0; i < length; i++) {
            if (experiments[i].Author == msg.sender) {
                sum++;
            }
        }
        Experiment[] memory myExperiment = new Experiment[](sum);
        uint j = 0;
        for (uint i = 0; i < length; i++) {
            if (experiments[i].Author == msg.sender) {
                myExperiment[j] = experiments[i];
                j++;
            }
        }
        return myExperiment;
    }
    function getAllExperimentInfo() public view returns (Experiment[] memory){
        return experiments;
    }
    //==============================string????????????==============================
    function strConcat(string memory _a, string memory _b) internal returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bret[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
        return string(ret);
    }

    function toString(address account) public pure returns (string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(uint256 value) public pure returns (string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes32 value) public pure returns (string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes memory data) public pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
}