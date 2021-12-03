/// @title Experiment -- Experiment Management
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.1
/// @date 2021-12-3
pragma solidity ^0.8.0;

contract Experiment {
    struct Experiment {
        uint256 Id;
        string Name;
        address Author;
        bytes32 Password;
        string Tag;
        bool Status;
        address[] Operators;

        string Class;
        string Description;
        uint256 Time;
    }

    struct File {
        string Path;
        bool enable;
    }

    mapping(uint256 => string[]) Filenames;
    mapping(uint256 => mapping(string => File)) Files;
    mapping(uint256 => mapping(address => uint256)) Scores;
    Experiment[] experiments;

    //查看当前调用用户是否有权限进行综合实验的修改
    modifier checkAuthority(uint256 _id){
        address author = experiments[_id].Author;
        require(msg.sender == author || checkIfAuthority(experiments[_id].Operators), "not authority");
        _;
    }
    //添加综合实验信息
    function addExperimentInfo(string memory _name, string memory _password, string memory _tag, bool _status, string memory _class, string memory _description, string memory _time) public returns (bool){
        uint256 nextid = experiments.length;
        Experiment memory experiment = Experiment({
        Id : nextid,
        Name : _name,
        Author : msg.sender,
        Password : keccak256(abi.encode(_password)),
        Tag : _tag,
        Status : _status,
        Operators : new address[](0),
        Class : _class,
        Description : _description,
        Time : block.timestamp}
        );
        experiments.push(experiment);
    }
    //获取综合实验信息
    function getExperimentInfo(uint256 _id) public returns (Experiment memory){
        Experiment memory retExperiment = experiments[_id];
        return retExperiment;
    }
    //修改综合实验信息
    function modifyExperimentInfo(uint256 _id, string memory _name, string memory _password, string memory _tag, bool _status, string memory _class, string memory _description, uint256 _time)
    public checkAuthority(_id) returns (bool){

        address author = experiments[_id].Author;

        experiments[_id].Name = _name;
        if (!hashCompareInternal(_password, "")) {
            experiments[_id].Password = keccak256(abi.encode(_password));
        }

        experiments[_id].Tag = _tag;
        experiments[_id].Status = _status;
        experiments[_id].Class = _class;
        experiments[_id].Description = _description;
        experiments[_id].Time = block.timestamp;
        return true;


    }
    //删除综合实验
    function disableExperiment(uint256 _id) public returns (bool){
        experiments[_id].Status = false;
    }
    //string类型的比较
    function hashCompareInternal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
    //查看当前地址是否在传入的地址数组中
    function checkIfAuthority(address[] memory _operators) public returns (bool){
        for (uint i = 0; i < _operators.length; i++) {
            if (_operators[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }
    //获取综合实验的上传信息
    function getExperimentUploadInfo(uint256 _id) public returns (string[] memory, string[] memory){
        string[] memory names = Filenames[_id];
        string[] memory paths;
        uint j = 0;
        for (uint i = 0; i < names.length; i++) {
            string memory filename = names[i];
            if (Files[_id][filename].enable) {
                string memory path = Files[_id][filename].Path;
                paths[j] = path;
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
            return true;
        }

    }
    //修改上传文件的信息
    function modifyExperimentUpload(uint256 _id, string memory _filepath, string memory _filename) checkAuthority(_id) public returns (bool){
        Files[_id][_filename].Path = _filepath;
        return true;
    }
    //删除上传文件的信息
    function deleteExperimentUpload(uint256 _id, string memory _filename) checkAuthority(_id) public returns (bool){
        Files[_id][_filename].enable = false;
        return true;
    }
    //添加operator
    function addOperator(uint256 _id, address _newOperator) checkAuthority(_id) public returns (bool){
        if (!checkIfExist(_newOperator, experiments[_id].Operators)) {
            experiments[_id].Operators.push(_newOperator);
            return true;
        }

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
    function addScore(uint256 _id, uint256 score) public returns (bool){
        Scores[_id][msg.sender] = score;
        return true;
    }

    function getAllMyCourseInfo() public returns (Experiment[] memory){
        Experiment[] memory myExperiment;
        uint length = experiments.length;
        uint j = 0;
        for (uint i = 0; i < length; i++) {
            if (experiments[i].Author == msg.sender) {
                myExperiment[j] = experiments[i];
                j++;
            }
        }
        return myExperiment;
    }


}