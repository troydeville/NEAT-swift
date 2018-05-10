import Foundation


public enum NeuronType {
    case input
    case hidden
    case bias
    case output
    case none
}

public enum ActivationType {
    
    case add
    case sigmoid
    case tanh
    case relu
    case sine
    case abs
    case square
    
}

public class NeuronGene {
    
    private var id: Int = 0
    private var type: NeuronType = NeuronType.none
    private var recurrent: Bool = false
    private var activationResponse: Double = 1
    private var xPos: Double = 0
    private var yPos: Double = 0
    private var activationType: ActivationType = ActivationType.sigmoid
    
    init(id: Int, type: NeuronType, x: Double, y: Double, rec: Bool, response: Double, activationType: ActivationType) {
        self.id = id
        self.type = type
        self.xPos = x
        self.yPos = y
        self.recurrent = rec
        self.activationResponse = response
        self.activationType = activationType
    }
    
    init() {}
    
    func getId() -> Int {
        return self.id
    }
    
    func getPos() -> CGPoint {
        return CGPoint(x: xPos, y: yPos)
    }
    
    func getXPos() -> Double {
        return self.xPos
    }
    
    func getYPos() -> Double {
        return self.yPos
    }
    
    func isRecurrent() -> Bool {
        return self.recurrent
    }
    
    func getType() -> NeuronType {
        return self.type
    }
    
    func isRecurrent(_ Recurrent: Bool) {
        self.recurrent = Recurrent
    }
    
    func getActivationResponse() -> Double {
        return self.activationResponse
    }
    
    func pertubeActivation(amount: Double) {
        self.activationResponse += amount
        
        if self.activationResponse > 100 {
            self.activationResponse = 100
        }
        if self.activationResponse < -100 {
            self.activationResponse = -100
        }
    }
    
    func changeActivation() {
        self.activationType = randomActivationType()
    }
    
    func getActivationType() -> ActivationType {
        return self.activationType
    }
    
    func toString() -> String {
        return "id: \(self.id), type: \(self.type), actType: \(self.activationType), rec: \(self.recurrent), actResp: \(self.activationResponse), position: (\(self.xPos), \(self.yPos))"
    }
    
}
