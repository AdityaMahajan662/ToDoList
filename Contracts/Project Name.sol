// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title ToDoList
 * @dev A decentralized to-do list application on blockchain
 * @author Your Name
 */
contract ToDoList {
    // Structure to represent a task
    struct Task {
        uint256 id;
        string content;
        bool completed;
        uint256 timestamp;
        address owner;
    }
    
    // State variables
    mapping(address => Task[]) private userTasks;
    mapping(address => uint256) private taskCounter;
    
    // Events
    event TaskCreated(address indexed user, uint256 indexed taskId, string content, uint256 timestamp);
    event TaskCompleted(address indexed user, uint256 indexed taskId, uint256 timestamp);
    event TaskDeleted(address indexed user, uint256 indexed taskId, uint256 timestamp);
    
    // Modifiers
    modifier validTaskId(uint256 _taskId) {
        require(_taskId < userTasks[msg.sender].length, "Task does not exist");
        require(userTasks[msg.sender][_taskId].owner == msg.sender, "Not the owner of this task");
        _;
    }
    
    modifier taskExists(uint256 _taskId) {
        require(_taskId < userTasks[msg.sender].length, "Task does not exist");
        _;
    }
    
    /**
     * @dev Create a new task
     * @param _content The content/description of the task
     */
    function createTask(string memory _content) public {
        require(bytes(_content).length > 0, "Task content cannot be empty");
        require(bytes(_content).length <= 500, "Task content too long");
        
        uint256 taskId = taskCounter[msg.sender];
        
        Task memory newTask = Task({
            id: taskId,
            content: _content,
            completed: false,
            timestamp: block.timestamp,
            owner: msg.sender
        });
        
        userTasks[msg.sender].push(newTask);
        taskCounter[msg.sender]++;
        
        emit TaskCreated(msg.sender, taskId, _content, block.timestamp);
    }
    
    /**
     * @dev Complete a task (mark as completed)
     * @param _taskId The ID of the task to complete
     */
    function completeTask(uint256 _taskId) public validTaskId(_taskId) {
        require(!userTasks[msg.sender][_taskId].completed, "Task already completed");
        
        userTasks[msg.sender][_taskId].completed = true;
        
        emit TaskCompleted(msg.sender, _taskId, block.timestamp);
    }
    
    /**
     * @dev Delete a task
     * @param _taskId The ID of the task to delete
     */
    function deleteTask(uint256 _taskId) public validTaskId(_taskId) {
        uint256 taskLength = userTasks[msg.sender].length;
        
        // Move the last task to the position of the task to be deleted
        if (_taskId < taskLength - 1) {
            userTasks[msg.sender][_taskId] = userTasks[msg.sender][taskLength - 1];
            // Update the ID of the moved task
            userTasks[msg.sender][_taskId].id = _taskId;
        }
        
        // Remove the last element
        userTasks[msg.sender].pop();
        
        emit TaskDeleted(msg.sender, _taskId, block.timestamp);
    }
    
    /**
     * @dev Get all tasks for the caller
     * @return Array of all user's tasks
     */
    function getTasks() public view returns (Task[] memory) {
        return userTasks[msg.sender];
    }
    
    /**
     * @dev Get a specific task by ID
     * @param _taskId The ID of the task to retrieve
     * @return The task details
     */
    function getTask(uint256 _taskId) public view taskExists(_taskId) returns (Task memory) {
        return userTasks[msg.sender][_taskId];
    }
    
    /**
     * @dev Get the total number of tasks for the caller
     * @return The total count of tasks
     */
    function getTaskCount() public view returns (uint256) {
        return userTasks[msg.sender].length;
    }
    
    /**
     * @dev Get the count of completed tasks for the caller
     * @return The count of completed tasks
     */
    function getCompletedTaskCount() public view returns (uint256) {
        uint256 completedCount = 0;
        Task[] memory tasks = userTasks[msg.sender];
        
        for (uint256 i = 0; i < tasks.length; i++) {
            if (tasks[i].completed) {
                completedCount++;
            }
        }
        
        return completedCount;
    }
    
    /**
     * @dev Get only completed tasks for the caller
     * @return Array of completed tasks
     */
    function getCompletedTasks() public view returns (Task[] memory) {
        uint256 completedCount = getCompletedTaskCount();
        Task[] memory completedTasks = new Task[](completedCount);
        Task[] memory allTasks = userTasks[msg.sender];
        
        uint256 index = 0;
        for (uint256 i = 0; i < allTasks.length; i++) {
            if (allTasks[i].completed) {
                completedTasks[index] = allTasks[i];
                index++;
            }
        }
        
        return completedTasks;
    }
    
    /**
     * @dev Get only pending (incomplete) tasks for the caller
     * @return Array of pending tasks
     */
    function getPendingTasks() public view returns (Task[] memory) {
        uint256 totalTasks = userTasks[msg.sender].length;
        uint256 completedCount = getCompletedTaskCount();
        uint256 pendingCount = totalTasks - completedCount;
        
        Task[] memory pendingTasks = new Task[](pendingCount);
        Task[] memory allTasks = userTasks[msg.sender];
        
        uint256 index = 0;
        for (uint256 i = 0; i < allTasks.length; i++) {
            if (!allTasks[i].completed) {
                pendingTasks[index] = allTasks[i];
                index++;
            }
        }
        
        return pendingTasks;
    }
    
    /**
     * @dev Toggle task completion status
     * @param _taskId The ID of the task to toggle
     */
    function toggleTaskCompletion(uint256 _taskId) public validTaskId(_taskId) {
        userTasks[msg.sender][_taskId].completed = !userTasks[msg.sender][_taskId].completed;
        
        if (userTasks[msg.sender][_taskId].completed) {
            emit TaskCompleted(msg.sender, _taskId, block.timestamp);
        }
    }
}
