/// @title Folder -- Folder Management
/// @author BloodMoon - <nerbonic@gmail.com>
/// @version 0.1
/// @date 2021-12-3
pragma solidity ^0.8.0;

contract Folder {
    struct Folder {
        uint256 Id;
        string Name;
        address Author;
        bool Status;
        address[] Operators;
        uint256[] ChildNode;
        uint256 FatherNode;
        string Class;
        string Tag;
        string Description;
        uint256[] CourseIds;
        uint256[] ExperimentIds;
        uint256 Time;
    }

    Folder[] Folders;
    mapping(uint256 => mapping(address => uint256)) Scores;

    function addFolder(string memory _name, uint256 _fatherNode, string memory _class, string memory _tag, string memory _description) public returns (bool){
        uint nextId = Folders.length;
        Folder memory folder = Folder({
        Id : nextId,
        Name : _name,
        Author : msg.sender,
        Status : true,
        Operators : new address[](0),
        ChildNode : new uint256[](0),
        FatherNode : _fatherNode,
        Class : _class,
        Tag : _tag,
        CourseIds : new uint256[](0),
        ExperimentIds : new uint256[](0),
        Description : _description,
        Time : block.timestamp}
        );
        Folders.push(folder);
        return true;
    }

    function addCourseToFolder(uint256 _folderId, uint256 _courseId) public returns (bool){
        if (checkIfExist(_courseId, Folders[_folderId].CourseIds)) {
            return false;
        }
        Folders[_folderId].CourseIds.push(_courseId);
        return true;
    }

    function addExperimentToFolder(uint256 _folderId, uint256 _experimentId) public returns (bool){
        if (checkIfExist(_experimentId, Folders[_folderId].ExperimentIds)) {
            return false;
        }
        Folders[_folderId].ExperimentIds.push(_experimentId);
        return true;
    }

    function modifyFolderInfo(uint256 _folderId, string memory _name, uint256 _fatherNode, string memory _class, string memory _tag, string memory _description) public returns (bool){
        Folders[_folderId].Name=_name;
        Folders[_folderId].FatherNode=_fatherNode;
        Folders[_folderId].Class=_class;
        Folders[_folderId].Tag=_tag;
        Folders[_folderId].Description=_description;
        return true;
    }

    function removeCourseToFolder(uint256 _folderId, uint256 _courseId) public returns (bool){
        removeCourseValueFromFolder(_folderId, _courseId);
        return true;
    }

    function removeExperimentToFolder(uint256 _folderId, uint256 _experimentId) public returns (bool){
        removeExperimentValueFromFolder(_folderId, _experimentId);
        return true;

    }

    function removeFolder(uint256 _folderId) public returns (bool){
        Folders[_folderId].Status = false;
        return true;
    }

    function getChildFoldersId(uint256 _folderId) public returns (uint256[] memory){
        return Folders[_folderId].ChildNode;
    }

    function getChildFoldersName(uint256 _folderId) public returns (string[] memory){
        uint256[] memory childs = Folders[_folderId].ChildNode;
        string[] memory names;
        uint j = 0;
        for (uint i = 0; i < childs.length; i++) {
            string memory folderName = Folders[childs[i]].Name;
            names[j] = folderName;
            j++;
        }
        return names;
    }
    //数组工具2
    function checkIfExist(uint256 adrs, uint256[] memory adrss) public returns (bool){
        for (uint i = 0; i < adrss.length; i++) {
            if (adrss[i] == adrs) {
                return true;
            }
        }
        return false;
    }

    function removeCourseIndexFromFolder(uint256 _folderId, uint256 _index) public {

        uint length = Folders[_folderId].CourseIds.length;
        if (_index == length - 1) {
            Folders[_folderId].CourseIds.pop();
        } else {
            Folders[_folderId].CourseIds[_index] = Folders[_folderId].CourseIds[length - 1];
            Folders[_folderId].CourseIds.pop();
        }
    }

    function removeCourseValueFromFolder(uint256 _folderId, uint256 _value) public {
        uint delIndex;
        for (uint i = 0; i < Folders[_folderId].CourseIds.length; i++) {
            if (Folders[_folderId].CourseIds[i] == _value) {
                delIndex = i;
            }
        }
        removeCourseIndexFromFolder(_folderId, delIndex);
    }

    function removeExperimentIndexFromFolder(uint256 _folderId, uint256 _index) public {

        uint length = Folders[_folderId].ExperimentIds.length;
        if (_index == length - 1) {
            Folders[_folderId].ExperimentIds.pop();
        } else {
            Folders[_folderId].ExperimentIds[_index] = Folders[_folderId].ExperimentIds[length - 1];
            Folders[_folderId].ExperimentIds.pop();
        }
    }

    function removeExperimentValueFromFolder(uint256 _folderId, uint256 _value) public {
        uint delIndex;
        for (uint i = 0; i < Folders[_folderId].ExperimentIds.length; i++) {
            if (Folders[_folderId].ExperimentIds[i] == _value) {
                delIndex = i;
            }
        }
        removeExperimentIndexFromFolder(_folderId, delIndex);
    }
}