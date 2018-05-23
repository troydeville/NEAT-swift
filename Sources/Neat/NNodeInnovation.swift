import Foundation

public struct NNodeInnovation {
    
    var innovationId: Int = 0
    let nodeId: Int
    
    init(nodeId: Int) {
        self.nodeId = nodeId
    }
    
    mutating func setInnovation(innovationId: Int) {
        self.innovationId = innovationId
    }
    
}


extension NNodeInnovation: Comparable {
    public static func < (lhs: NNodeInnovation, rhs: NNodeInnovation) -> Bool {
        return lhs.nodeId < rhs.nodeId
    }
    
    public static func == (lhs: NNodeInnovation, rhs: NNodeInnovation) -> Bool {
        return lhs.nodeId == rhs.nodeId
    }
    
}
