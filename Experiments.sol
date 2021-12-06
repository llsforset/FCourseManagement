/// @title Experiment -- Experiment Management
/// @author BloodMoon - <nerbonic@gmail.com>
/// @author 5579 -<1025714986@qq.com>
/// @version 0.1
/// @date 2021-12-3
import "./ILog.sol";

pragma solidity ^0.8.0;

contract Experiment {
    struct Experiment {
        uint256 Id;
        string Name;
        address Author;
        string Tag;
        bool Status;
        address[] Operators;

        string Class;
        string Description;
        uint256 Time;
        uint256 BlockNum;
    }

    struct File {
        string Path;
        bool enable;
    }

    ILog iLog;

    mapping(uint256 => string[]) Filenames;
    mapping(uint256 => mapping(string => File)) Files;
    mapping(uint256 => address[]) arrayScores;
    mapping(uint256 => mapping(address => uint256)) Scores;
    Experiment[] experiments;
    constructor(address adrs){
        iLog = ILog(adrs);
    }

    //查看当前调用用户是否有权限进行综合实验的修改
    modifier checkAuthority(uint256 _id){
        address author = experiments[_id].Author;
        require(msg.sender == author || checkIfAuthority(experiments[_id].Operators), "not authority");
        _;
    }
    //添加综合实验信息
    function addExperimentInfo(string memory _name, string memory _tag, bool _status, string memory _class, string memory _description) public returns (Experiment memory){
        require(!checkIfMyExperimentNameExist(_name), "name exist");
        uint256 nextid = experiments.length;
        Experiment memory experiment = Experiment({
        Id : nextid,
        Name : _name,
        Author : msg.sender,
        Tag : _tag,
        Status : _status,
        Operators : new address[](0),
        Class : _class,
        Description : _description,
        Time : block.timestamp,
        BlockNum : block.number}
        );
        experiments.push(experiment);
        iLog.addLog("Experiment", "addExperimentInfo", msg.sender, nextid, true);
        return experiment;
    }
    //避免一个作者重复添加实验
    function checkIfMyExperimentNameExist(string memory _name) public returns (bool){
        uint length = experiments.length;
        for (uint i = 0; i < length; i++) {
            if (experiments[i].Author == msg.sender && hashCompareInternal(_name, experiments[i].Name)) {
                return true;
            }
        }
        return false;
    }
    //获取综合实验信息
    function getExperimentInfo(uint256 _id) public view returns (Experiment memory){
        Experiment memory retExperiment = experiments[_id];
        return retExperiment;
    }
    //修改综合实验信息
    function modifyExperimentInfo(uint256 _id, string memory _name, string memory _tag, bool _status, string memory _class, string memory _description)
    public checkAuthority(_id) returns (Experiment memory){

        address author = experiments[_id].Author;

        experiments[_id].Name = _name;

        experiments[_id].Tag = _tag;
        experiments[_id].Status = _status;
        //需要输入true或false、输入任意值或不输入
        experiments[_id].Class = _class;
        experiments[_id].Description = _description;
        experiments[_id].Time = block.timestamp;

        iLog.addLog("Experiment", "modifyExperimentInfo", msg.sender, _id, true);
        return experiments[_id];


    }
    //删除综合实验
    function disableExperiment(uint256 _id) public returns (bool){
        experiments[_id].Status = false;
        iLog.addLog("Experiment", "disableExperiment", msg.sender, _id, true);
        return true;
    }
    //string类型的比较
    function hashCompareInternal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
    //查看当前地址是否在操作者地址数组中
    function checkIfAuthority(address[] memory _operators) private returns (bool){
        for (uint i = 0; i < _operators.length; i++) {
            if (_operators[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }
    //获取综合实验的上传信息
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
    //添加上传文件的信息
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
    //修改上传文件的信息
    function modifyExperimentUpload(uint256 _id, string memory _filepath, string memory _filename) checkAuthority(_id) public returns (bool){
        Files[_id][_filename].Path = _filepath;
        iLog.addLog("Experiment", strConcat("modifyExperimentUpload", _filepath), msg.sender, _id, true);
        return true;
    }
    //删除上传文件的信息
    function deleteExperimentUpload(uint256 _id, string memory _filename) checkAuthority(_id) public returns (bool){
        Files[_id][_filename].enable = false;
        iLog.addLog("Experiment", "deleteExperimentUpload", msg.sender, _id, true);
        return true;
    }
    //重新启用上传文件
    function enableExperimentUpload(uint256 _id, string memory _filename) checkAuthority(_id) public returns (bool){
        Files[_id][_filename].enable = true;
        iLog.addLog("Experiment", "enableExperimentUpload", msg.sender, _id, true);
        return true;
    }
    //查看上传文件状态
    function getExperimentUpload(uint256 _id, string memory _filename) public view returns (bool){
        return Files[_id][_filename].enable;
    }
    //添加operator
    function addOperator(uint256 _id, address _newOperator) checkAuthority(_id) public returns (bool){
        if (!checkIfExist(_newOperator, experiments[_id].Operators)) {
            experiments[_id].Operators.push(_newOperator);
            iLog.addLog("Experiment", strConcat("addOperatorSucceed", toString(_newOperator)), msg.sender, _id, true);
            return true;
        }
        iLog.addLog("Experiment", strConcat("addOperatorFail", toString(_newOperator)), msg.sender, _id, true);
        return false;

    }
    //数组工具1
    function checkIfExist(address adrs, address[] memory adrss) public returns (bool){
        for (uint i = 0; i < adrss.length; i++) {
            if (adrss[i] == adrs) {
                return true;
            }
        }
        return false;
    }
    //数组工具2
    function checkIfExist(string memory adrs, string[] memory adrss) public returns (bool){
        for (uint i = 0; i < adrss.length; i++) {
            if (hashCompareInternal(adrss[i], adrs)) {
                return true;
            }
        }
        return false;
    }
    //打分
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
    //平均分统计
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
    //==============================string工具函数==============================
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