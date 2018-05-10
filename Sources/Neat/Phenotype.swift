import Foundation


class Phenotype {
    
    var depth: Int = 0
    var neurons: [Neuron] = [Neuron]()
    
    init() {}
    
    init(depth: Int, neurons: [Neuron]) {
        self.depth = depth
        self.neurons.removeAll()
        self.neurons = neurons
    }
    
    func clear() {
        self.depth = 0
        for n in 0..<self.neurons.count {
            self.neurons[n].clear()
            
        }
        self.neurons = []
    }
    
}
