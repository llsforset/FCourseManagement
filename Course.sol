/// @title Course -- Course Management
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.1
/// @date 2021-12-3
import "./ILog.sol";
pragma solidity ^0.8.0;

contract Course {
    struct Course {
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
    Course[] courses;
    constructor(address adrs){
        iLog = ILog(adrs);
    }
    //查看当前调用用户是否有权限进行课件的修改
    modifier checkAuthority(uint256 _id){
        address author = courses[_id].Author;
        require(msg.sender == author || checkIfAuthority(courses[_id].Operators), "not authority");
        _;
    }
    //添加课件信息
    function addCourseInfo(string memory _name, string memory _tag, bool _status, string memory _class, string memory _description) public returns (Course memory){
        require(!checkIfMyCourseNameExist(_name), "name exist");
        uint256 nextid = courses.length;
        Course memory course = Course({
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
        courses.push(course);
        iLog.addLog("Course", "addCourse", msg.sender, nextid, true);
        return course;
    }
    //获取课件信息
    function getCourseInfo(uint256 _id) public view returns (Course memory){
        Course memory retCourse = courses[_id];
        return retCourse;
    }
    //修改课件信息
    function modifyCourseInfo(uint256 _id, string memory _name, string memory _tag, bool _status, string memory _class, string memory _description)
    public checkAuthority(_id) returns (Course memory){

        address author = courses[_id].Author;

        courses[_id].Name = _name;
        courses[_id].Tag = _tag;
        courses[_id].Status = _status;
        courses[_id].Class = _class;
        courses[_id].Description = _description;
        courses[_id].Time = block.timestamp;
        iLog.addLog("Course", "modifyCourseInfo", msg.sender, _id, true);
        return courses[_id];


    }
    //删除课件
    function disableCourse(uint256 _id) checkAuthority(_id) public returns (bool){
        courses[_id].Status = false;
        iLog.addLog("Course", "disableCourse", msg.sender, _id, true);
        return true;
    }
    //string类型的比较 作用？？
    function hashCompareInternal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
    //查看当前地址是否在传入的地址数组中
    function checkIfAuthority(address[] memory _operators) private returns (bool){
        for (uint i = 0; i < _operators.length; i++) {
            if (_operators[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }
    //获取课件的上传信息
    function getCourseUploadInfo(uint256 _id) public view returns (string[] memory, string[] memory){
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
    //TODO:需要一个检查当前文件名是否存在数组当中(view)
    function addCourseUpload(uint256 _id, string memory _filepath, string memory _filename) checkAuthority(_id) public returns (bool){
        if (checkIfExist(_filename, Filenames[_id])) {return false;}
        else {
            Filenames[_id].push(_filename);
            File memory file = File({Path : _filepath, enable : true});
            Files[_id][_filename] = file;
            iLog.addLog("Course", "Upload", msg.sender, _id, true);
            return true;
        }
    }

    function checkUploadIfExist(uint256 _id, string memory _filename) public returns (bool){
        return !checkIfExist(_filename, Filenames[_id]);
    }
    //修改上传文件的信息
    function modifyCourseUpload(uint256 _id, string memory _filepath, string memory _filename) checkAuthority(_id) public returns (bool){
        Files[_id][_filename].Path = _filepath;
        iLog.addLog("Course", strConcat("modifyUpload:", _filename), msg.sender, _id, true);
        return true;
    }
    //删除上传文件的信息
    function deleteCourseUpload(uint256 _id, string memory _filename) checkAuthority(_id) public returns (bool){
        Files[_id][_filename].enable = false;
        iLog.addLog("Course", strConcat("deleteUpload:", _filename), msg.sender, _id, true);
        return true;
    }
    //重新启用上传文件
    function enableCourseUpload(uint256 _id, string memory _filename) checkAuthority(_id) public returns (bool){
        Files[_id][_filename].enable = true;
        iLog.addLog("Course", strConcat("enableUpload:", _filename), msg.sender, _id, true);
        return true;
    }
    //查看上传文件是否删除
    function getCourseUpload(uint256 _id, string memory _filename) view public returns (bool){
        return Files[_id][_filename].enable;
    }

    //添加operator
    //TODO2:仅作者操作
    function addOperator(uint256 _id, address _newOperator) checkAuthority(_id) public returns (bool){
        if (!checkIfExist(_newOperator, courses[_id].Operators)) {
            courses[_id].Operators.push(_newOperator);
            iLog.addLog("Course", strConcat("addOperator:", toString(_newOperator)), msg.sender, _id, true);
            return true;
        }
        iLog.addLog("Course", strConcat("addOperator:", toString(_newOperator)), msg.sender, _id, false);
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
            iLog.addLog("Course", strConcat(strConcat(toString(msg.sender), "-Score-"), toString(score)), msg.sender, _id, true);

        } else {
            Scores[_id][msg.sender] = score;
            arrayScores[_id].push(msg.sender);
            iLog.addLog("Course", strConcat(strConcat(toString(msg.sender), "-ReScore-"), toString(score)), msg.sender, _id, true);
        }
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

    function checkIfMyCourseNameExist(string memory _name) public returns (bool){
        uint length = courses.length;
        for (uint i = 0; i < length; i++) {
            if (courses[i].Author == msg.sender && hashCompareInternal(_name, courses[i].Name)) {
                return true;
            }
        }
        return false;
    }

    function getAllMyCourseInfo() public view returns (Course[] memory){

        uint length = courses.length;
        uint sum = 0;
        for (uint i = 0; i < length; i++) {
            if (courses[i].Author == msg.sender) {
                sum++;
            }
        }
        Course[] memory myCourses = new Course[](sum);
        uint j = 0;
        for (uint i = 0; i < length; i++) {
            if (courses[i].Author == msg.sender) {
                myCourses[j] = courses[i];
                j++;
            }
        }
        return myCourses;
    }
    function getAllCourseInfo() public view returns (Course[] memory){
        return courses;
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