import Foundation


class Innovation {
    
    private var innovationID: Int
    private var neuronIn: Int
    private var neuronOut: Int
    private var neuronID: Int
    private var neuronType: NeuronType
    private var neuronActivationType: ActivationType
    private var yPos: Double
    private var xPos: Double
    private var recurrent: Bool
    
    init(innovationID: Int, neuronIn: Int, neuronOut: Int) {
        self.innovationID = innovationID
        self.neuronIn = neuronIn
        self.neuronOut = neuronOut
        self.neuronID = -1
        self.neuronType = NeuronType.none
        self.xPos = 0
        self.yPos = 0
        self.recurrent = false
        self.neuronActivationType = ActivationType.sigmoid
    }
    
    init(innovationID: Int, from: Int, to: Int, type: NeuronType, activationType: ActivationType, xPos: Double, yPos: Double, neuronID: Int, recurrent: Bool) {
        self.innovationID = innovationID
        self.neuronIn = from
        self.neuronOut = to
        self.neuronType = type
        self.xPos = xPos
        self.yPos = yPos
        self.neuronID = neuronID
        self.recurrent = recurrent
        self.neuronActivationType = activationType
    }
    
    func getActivationType() -> ActivationType {
        return self.neuronActivationType
    }
    
    func getInnovationID() -> Int {
        return self.innovationID
    }
    
    func getNeuronIn_id() -> Int {
        return self.neuronIn
    }
    
    func getNeuronOut_id() -> Int {
        return self.neuronOut
    }
    
    func getNeuronID() -> Int {
        return self.neuronID
    }
    
    func getType() -> NeuronType {
        return self.neuronType
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
    
}

