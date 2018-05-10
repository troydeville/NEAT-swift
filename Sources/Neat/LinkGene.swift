import Foundation


public class LinkGene {
    
    private var from: Int = 0
    private var to: Int = 0
    private var weight: Double = 0
    private var enabled: Bool = true
    private var recurrent: Bool = false
    private var innovation: Int = 0
    
    init() { }
    
    init(i: Int, o: Int, w: Double, en: Bool, inov: Int, rec: Bool) {
        self.from = i
        self.to = o
        self.weight = w
        self.enabled = en
        self.recurrent = rec
        self.innovation = inov
    }
    
    func pertubeWeight(amount: Double) {
        self.weight += amount
        
        if self.weight > 100 {
            self.weight = 100
        }
        if self.weight < -100 {
            self.weight = -100
        }
        
    }
    
    func getFrom() -> Int {
        return self.from
    }
    
    func getTo() -> Int {
        return self.to
    }
    
    func getInnovation() -> Int {
        return self.innovation
    }
    
    func isEnabled() -> Bool {
        return self.enabled
    }
    
    func isEnabled(_ en: Bool) {
        self.enabled = en
    }
    
    func isRecurrent() -> Bool {
        return self.recurrent
    }
    
    func getWeight() -> Double {
        return self.weight
    }
    
    func toString() -> String {
        return "from: \(self.from), to: \(self.to), weight: \(self.weight), en: \(self.enabled), rec: \(self.recurrent), innovation: \(self.innovation)"
    }
    
    func flipEnable() {
        self.enabled = !self.enabled
    }
    
    func enableConnection(_ val: Bool) {
        self.enabled = val
    }
    
}
