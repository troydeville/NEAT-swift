import Foundation


public class Database {
    
    private var innovationNumber = 1
    private var neuronID: Int = 1
    private var genomeID: Int = 0
    private var speciesID: Int = 0
    private var innovations: [Innovation] = [Innovation]()
    
    let nodeMutChance: Double = 0.03
    let connectionMutChance: Double = 0.15
    let weightMutChance: Double = 0.80
    let activationMutChance: Double = 0.1
    let weightPertubeAmount: Double = 0.3
    let activationPertubeAmount: Double = 1
    let enableMutChance: Double = 0.3
    let disableMutChance: Double = 0.0
    let changeActivType: Double = 0.0
    private var population: Int = 0
    var inputs: Int
    var outputs: Int
    
    init(inputs: Int, outputs: Int) {
        self.inputs = inputs
        self.outputs = outputs
    }
    
    /*
     init(inputs: Int, outputs: Int) {
     self.neuronID = inputs + outputs
     }
     */
    
    func checkInnovation(id_1: Int, id_2: Int, neuronID: Int) -> Int {
        for inov in innovations {
            if (inov.getNeuronIn_id() == id_1) && (inov.getNeuronOut_id() == id_2) && (inov.getNeuronID() == neuronID) {
                return inov.getInnovationID()
            }
        }
        return -1
    }
    
    func setPopulation(pop: Int) {
        self.population = pop
    }
    
    func getPopulation() -> Int {
        return self.population
    }
    
    func populationSize() -> Int {
        return self.population
    }
    
    func createNewLinkInnovation(neuron1_id: Int, neuron2_id: Int) {
        self.innovations += [Innovation(innovationID: self.innovationNumber, neuronIn: neuron1_id, neuronOut: neuron2_id)]
        self.innovationNumber += 1
    }
    
    func nextInnovation() -> Int {
        self.innovationNumber += 1
        return self.innovationNumber
    }
    
    
    func currentInnovation() -> Int {
        return self.innovationNumber
    }
    
    func nextGenomeID() -> Int {
        genomeID += 1
        return genomeID
    }
    
    func getNeuronId(id: Int) -> Int {
        for inov in innovations {
            if inov.getNeuronID() == id {
                return inov.getNeuronID()
            }
        }
        return -1
    }
    
    func createNewNodeInnovation(from: Int, to: Int, type: NeuronType, activationType: ActivationType, xPos: Double, yPos: Double) -> Int {
        innovations += [Innovation(innovationID: self.innovationNumber, from: from, to: to, type: type, activationType: activationType, xPos: xPos, yPos: yPos, neuronID: self.neuronID, recurrent: false)]
        self.innovationNumber += 1
        self.neuronID += 1
        return self.neuronID - 1
    }
    
    func getNodeByID(id: Int) -> NeuronGene {
        
        for innovation in innovations {
            if (innovation.getNeuronID() == id) {
                return NeuronGene(id: id, type: innovation.getType(), x: innovation.getXPos(), y: innovation.getYPos(), rec: innovation.isRecurrent(), response: 1, activationType: innovation.getActivationType())
            }
        }
        
        print("returned blank")
        return NeuronGene()
    }
    
    func checkNodeInLink(from: Int, to: Int) -> Int {
        for i in innovations {
            if (i.getNeuronIn_id() == from) && (i.getNeuronOut_id() == to)  && (i.getType() == NeuronType.hidden) {
                return i.getNeuronID()
            }
        }
        return -1
    }
    
    func nextSpeciesID() -> Int {
        self.speciesID += 1
        return self.speciesID
    }
    
}
