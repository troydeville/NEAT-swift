import Foundation

struct NNetworkNode {
    
    var id: Int
    var position: Double
    
    init(id: Int, position: NPosition) {
        self.id = id
        self.position = position.y
    }
    
}

extension NNetworkNode: Comparable {
    public static func < (lhs: NNetworkNode, rhs: NNetworkNode) -> Bool {
        return lhs.position < rhs.position
    }
    
    public static func == (lhs: NNetworkNode, rhs: NNetworkNode) -> Bool {
        return lhs.position == rhs.position
    }
}
