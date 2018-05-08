//
//  NeuralNet.swift
//  NEAT
//
//  Created by Troy Deville on 7/18/17.
//  Copyright © 2017 Troy Deville. All rights reserved.
//

import Foundation



class NeuralNet {
    
    private var neurons: [Neuron]
    private var depth: Int
    
    init(neurons: [Neuron], depth: Int) {
        self.neurons = neurons
        self.depth = depth
    }
    
    func update(inputs: [Double], type: RunType) -> [Double] {
        var outputs: [Double] = [Double]()
        
        var flushCount: Int = 0
        
        if type == RunType.active {
            flushCount = self.depth
        } else {
            flushCount = 1
        }
        
        for _ in 1...flushCount {
            outputs.removeAll()
            
            var cNeuron: Int = 0
            
            while self.neurons[cNeuron].type == NeuronType.input {
                self.neurons[cNeuron].output = inputs[cNeuron]
                cNeuron += 1
                //print("stuckd")
            }
            
            // Set bias to 1
            self.neurons[cNeuron].output = 1.0
            cNeuron += 1
            
            while cNeuron < self.neurons.count {
                //print("stucke")
                var sum: Double = 0
                
                for lnk in 0..<self.neurons[cNeuron].incommingLinks.count {
                    let weight: Double = self.neurons[cNeuron].incommingLinks[lnk].weight
                    let neuronOutput: Double = self.neurons[cNeuron].incommingLinks[lnk].neuron_in.output
                    sum += weight * neuronOutput
                }
                
                self.neurons[cNeuron].output = Sigmoid(x: sum, response: self.neurons[cNeuron].activationResponse)
                
                if neurons[cNeuron].type == NeuronType.output {
                    outputs += [neurons[cNeuron].output]
                }
                
                cNeuron += 1
            }
            
        }
        
        if type == RunType.snapshot {
            for n in 0..<self.neurons.count {
                self.neurons[n].output = 0
            }
        }
        
        return outputs
    }
    
}







