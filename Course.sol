pragma solidity ^0.8.0;
contract Course{
    struct Course{
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

    mapping(uint256=>mapping(string=>string)) filepaths;
    mapping(uint256=>mapping(address=>uint256)) Scores;
    Course[] courses;

    modifier checkAuthority(uint256 _id){
        address author=courses[_id].Author;
        require(msg.sender==author||checkIfAuthority(courses[_id].Operators),"not authority");
        _;
    }
    function addCourseInfo(string memory _name,string memory _password,string memory _tag,bool _status,string memory _class,string memory _description,string memory _time) public returns(bool){
        uint256 nextid=courses.length;
        Course memory course=Course({
        Id:nextid,
        Name:_name,
        Author:msg.sender,
        Password:keccak256(abi.encode(_password)),
        Tag:_tag,
        Status:_status,
        Operators:new address[](0),
        Class:_class,
        Description:_description,
        Time:block.timestamp}
        );
        courses.push(course);
    }
    function getCourseInfo(uint256 _id) public returns(Course memory){
        Course memory retCourse=courses[_id];
        return retCourse;
    }
    function modifyCourseInfo(uint256 _id,string memory _name,string memory _password,string memory _tag,bool _status,string memory _class,string memory _description,uint256 _time)
    public checkAuthority(_id) returns(bool){

        address author=courses[_id].Author;

        courses[_id].Name=_name;
        if(!hashCompareInternal(_password,"")){
            courses[_id].Password=keccak256(abi.encode(_password));
        }

        courses[_id].Tag=_tag;
        courses[_id].Status=_status;
        courses[_id].Class=_class;
        courses[_id].Description=_description;
        courses[_id].Time=block.timestamp;
        return true;


    }
    function disableCourse(uint256 _id) public returns(bool){
        courses[_id].Status=false;
    }
    function hashCompareInternal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
    function checkIfAuthority(address[] memory _operators) public returns(bool){
        for(uint i=0;i<_operators.length;i++){
            if(_operators[i]==msg.sender){
                return true;
            }
        }
        return false;
    }
    function modifyCourseUpload(uint256 _id,string memory _filepath,string memory _filename) checkAuthority(_id) public returns(bool){
        address author=courses[_id].Author;
        filepaths[_id][_filename]=_filepath;
        return true;

    }

    function addOperator(uint256 _id,address _newOperator) checkAuthority(_id) public returns(bool){
        if(!checkIfExist(_newOperator,courses[_id].Operators)){
            courses[_id].Operators.push(_newOperator);
            return true;
        }

        return false;

    }
    function checkIfExist(address adrs,address[] memory adrss) public returns(bool){
        for(uint i=0;i<adrss.length;i++){
            if(adrss[i]==adrs){
                return true;
            }
        }
        return false;
    }
    function addScore(uint256 _id,uint256 score) public returns(bool){
        Scores[_id][msg.sender]=score;
        return true;
    }

}