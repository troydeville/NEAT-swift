import Foundation

public struct NLink {
    
    let innovation: Int
    
    let to: Int
    let from: Int
    
    var weight: Double
    var enabled: Bool
    var recurrent: Bool
    
    init(innovation: Int, to: Int, from: Int) {
        self.innovation = innovation
        self.to = to
        self.from = from
        if from == 3 {
            self.weight = 1
        } else {
            self.weight = NRandom()
        }
        
        //self.weight = 1.0
        self.enabled = true
        self.recurrent = false
    }
    
    init(innovation: Int, to: Int, from: Int, weight: Double, enabled: Bool, recurrent: Bool) {
        self.innovation = innovation
        self.to = to
        self.from = from
        self.weight = weight
        self.enabled = enabled
        self.recurrent = recurrent
    }
    
    mutating func perturbWeight(amount: Double) {
        self.weight += amount
        if self.weight > 5 {
            self.weight = 5
        } else if self.weight < -5 {
            self.weight = -5
        }
    }
    
    mutating func disable() {
        self.enabled = false
    }
    
    mutating func enable() {
        self.enabled = true
    }
    
    mutating func isRecurrent(isRecurrent: Bool) {
        self.recurrent = isRecurrent
    }
    
}

extension NLink: Comparable {
    public static func < (lhs: NLink, rhs: NLink) -> Bool {
        return lhs.innovation > rhs.innovation
    }
    
    public static func == (lhs: NLink, rhs: NLink) -> Bool {
        return lhs.innovation == rhs.innovation
    }
}
