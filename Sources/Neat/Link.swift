//
//  Link.swift
//  NEAT
//
//  Created by Troy Deville on 7/18/17.
//  Copyright © 2017 Troy Deville. All rights reserved.
//

import Foundation

class Link {
    
    var neuron_in: Neuron
    var neuron_out: Neuron
    var weight: Double
    var recurrent: Bool
    
    init(w: Double, n_in: Neuron, n_out: Neuron, rec: Bool) {
        self.neuron_in = n_in
        self.neuron_out = n_out
        self.weight = w
        self.recurrent = rec
    }
    
    func clear() {
        neuron_in.removeIncomingOutgoing()
        neuron_out.removeIncomingOutgoing()
    }
    
}
