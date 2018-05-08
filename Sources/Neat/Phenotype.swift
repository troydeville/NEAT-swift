//
//  Phenotype.swift
//  NEAT
//
//  Created by Troy Deville on 7/18/17.
//  Copyright © 2017 Troy Deville. All rights reserved.
//

import Foundation

class Phenotype {
    
    var depth: Int = 0
    var neurons: [Neuron] = [Neuron]()
    
    init() {}
    
    init(depth: Int, neurons: [Neuron]) {
        self.depth = depth
        self.neurons.removeAll()
        /*
        for n in 0..<neurons.count {
            self.neurons += [Neuron(neuron: neurons[n])]
        }
 */
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
