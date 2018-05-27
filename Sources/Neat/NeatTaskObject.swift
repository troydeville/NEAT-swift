import Foundation


public class NeatTaskObject {
    
    var taskComplete = false
    
    init() { }
    
    
    public func task(_ neatTask: @escaping() -> Void) {
        neatTask()
        self.taskComplete = true
    }
    
    public func task(_ neatTask: (Int) -> Void, _ value: Int) {
        neatTask(value)
        self.taskComplete = true
    }
    
    public func isCompleted() -> Bool {
        return taskComplete
    }
    
    public func isCompleted(_ isComplete: Bool) {
        self.taskComplete = isComplete
    }
    
}








