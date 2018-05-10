import Foundation


public class Neuron {
    
    var incommingLinks: [Link] = [Link]()
    var outgoingLinks: [Link] = [Link]()
    var sumActivation: Double = 0
    var output: Double = 0
    var type: NeuronType
    var id: Int
    var activationResponse: Double
    var xPos: Int = 0
    var yPos: Int = 0
    var xSplit: Double = 0
    var ySplit: Double = 0
    var activationType: ActivationType
    
    init(neuron: NeuronGene) {
        self.type = neuron.getType()
        self.id = neuron.getId()
        self.activationResponse = neuron.getActivationResponse()
        self.xSplit = neuron.getXPos()
        self.ySplit = neuron.getYPos()
        self.activationType = neuron.getActivationType()
    }
    
    init(neuron: Neuron) {
        self.incommingLinks = neuron.incommingLinks
        self.outgoingLinks = neuron.outgoingLinks
        self.sumActivation = neuron.sumActivation
        self.output = neuron.output
        self.type = neuron.type
        self.id = neuron.id
        self.activationResponse = neuron.activationResponse
        self.xPos = neuron.xPos
        self.yPos = neuron.yPos
        self.xSplit = neuron.xSplit
        self.ySplit = neuron.ySplit
        self.activationType = neuron.activationType
        
    }
    
    func addIncommingLink(link: Link) {
        let l = Link(w: link.weight, n_in: link.neuron_in, n_out: link.neuron_out, rec: link.recurrent)
        self.incommingLinks += [l]
    }
    
    func addOutgoingLink(link: Link) {
        let l = Link(w: link.weight, n_in: link.neuron_in, n_out: link.neuron_out, rec: link.recurrent)
        self.outgoingLinks += [l]
    }
    
    func clear() {
        removeIncomingOutgoing()
    }
    
    func removeIncomingOutgoing() {
        self.outgoingLinks = []
        self.incommingLinks = []
    }
    
    func setOutput(o: Double) {
        self.output = o
    }
    
}
