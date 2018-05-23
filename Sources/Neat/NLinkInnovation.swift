import Foundation


public struct NLinkInnovation {
    
    var innovationID: Int = 0
    var nIn: Int
    var nOut: Int
    var enabled: Bool
    var weight: Double
    
    init(innovationId: Int, nIn: Int, nOut: Int, enabled: Bool, weight: Double) {
        self.innovationID = innovationId
        self.nIn = nIn
        self.nOut = nOut
        self.enabled = enabled
        self.weight = weight
    }
    
    mutating func setInnovation(innovationID: Int) {
        self.innovationID = innovationID
    }
    
}

extension NLinkInnovation: Comparable {
    public static func < (lhs: NLinkInnovation, rhs: NLinkInnovation) -> Bool {
        return lhs.innovationID < rhs.innovationID
    }
    
    public static func == (lhs: NLinkInnovation, rhs: NLinkInnovation) -> Bool {
        return lhs.innovationID == rhs.innovationID
    }
    
}
