import Foundation

public struct NNode {
    
    let id: Int
    
    var incommingLinks = [NLink]()
    var outgoingLinks = [NLink]()
    
    var input = [Double]()
    var output = Double()
    
    var type: NType = NType.none
    var activation: NActivation = NActivation.sigmoid
    
    var activationResponse: Double = 1
    
    var position: NPosition = NPosition()
    
    init(id: Int, type: NType, position: NPosition, activation: NActivation) {
        self.id = id
        self.type = type
        self.position = position
        self.activation = activation
    }
    
    init(id: Int) { self.id = id }
    
    mutating func appendIncommingLink(link: NLink) { self.incommingLinks += [link] }
    mutating func appendOutgoingLink(link: NLink) { self.outgoingLinks += [link] }
    
}

extension NNode: Comparable {
    public static func == (lhs: NNode, rhs: NNode) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static func < (lhs: NNode, rhs: NNode) -> Bool {
        return lhs.id < rhs.id
    }
}
