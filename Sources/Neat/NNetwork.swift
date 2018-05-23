import Foundation

public struct NNetwork {
    
    var nodes: BTree<Int, NNode> = BTree(order: BTREEORDER)!
    var links: BTree<Int, NLink> = BTree(order: BTREEORDER)!
    
    var nodeIds = [Int]()
    
    init(genome: NGenome) {
        
        self.links = genome.getLinks()
        self.nodeIds.removeAll()
        //print("NODES EHRE@!@$LK!J#KL!@JKL!J#KL")
        //print(genome.getNodes())
        
        for node in genome.getNodes() {
            self.nodes.insert(node, for: node.id)
            //print("\nid: \(node.id)")
            //print("Incomming links: \(node.incommingLinks)")
            //print("Outgoing links: \(node.outgoingLinks)\n")
        }
        
        for l in self.links.inorderArrayFromKeys {
            let link = self.links.value(for: l)!
            
            //print("\(link.from):\(link.to)")
            
            var fromNode = self.nodes.value(for: link.from)!
            fromNode.appendOutgoingLink(link: link)
            self.nodes.insert(fromNode, for: link.from)
            
            var toNode = self.nodes.value(for: link.to)!
            toNode.appendIncommingLink(link: link)
            self.nodes.insert(toNode, for: link.to)
        }
        
        nodeIds = self.nodes.inorderArrayFromKeys
        //print("Node ids: \(nodeIds)")
        //print(nodes)
    }
    
    /*
    
    mutating func run(inputs: [Double], active: Bool) -> [Double] {
        var outputs = [Double]()
        
        var flushCount = 0
        
        if active {
            flushCount = self.getDepth()
        } else {
            flushCount = 1
        }
        
        for _ in 1...flushCount {
            
            // Clear the outputs.
            outputs.removeAll()
            
            for id in 0..<nodeIds.count {
                
                var node = self.nodes.value(for: nodeIds[id])!
                if node.type == NType.input {
                    node.output = Sigmoid(x: inputs[id], response: node.activationResponse) * node.outgoingLinks.first!.weight
                    nodes.insert(node, for: nodeIds[id])
                } else if node.type == NType.bias {
                    node.output = Sigmoid(x: 1, response: node.activationResponse) * node.outgoingLinks.first!.weight
                    nodes.insert(node, for: nodeIds[id])
                } else {
                    
                    var sum = 0.0
                    
                    for link in node.incommingLinks {
                        // Get link's weight
                        let weight = link.weight
                        
                        
                        // Get output from node this link is coming from
                        if link.enabled {
                            let nodeOutput = self.nodes.value(for: link.from)!.output * link.weight
                            sum += weight * nodeOutput
                        }
 
                        /*
                        let nodeOutput = self.nodes.value(for: link.from)!.output * link.weight
                        sum += weight * nodeOutput
                        */
                        
                        //print("Sum: \(sum)")
                    }//end
                    
                    let type = node.activation
                    switch type {
                    case NActivation.sigmoid:
                        node.output = Sigmoid(x: sum, response: node.activationResponse)
                        nodes.insert(node, for: nodeIds[id])
                    case NActivation.add:
                        node.output = Add(x: sum, response: node.activationResponse)
                        nodes.insert(node, for: nodeIds[id])
                    case NActivation.tanh:
                        node.output = Tanh(x: sum, response: node.activationResponse)
                        nodes.insert(node, for: nodeIds[id])
                    case NActivation.relu:
                        node.output = Relu(x: sum, response: node.activationResponse)
                        nodes.insert(node, for: nodeIds[id])
                    case NActivation.sine:
                        node.output = Sine(x: sum, response: node.activationResponse)
                        nodes.insert(node, for: nodeIds[id])
                    case NActivation.abs:
                        node.output = Abs(x: sum, response: node.activationResponse)
                        nodes.insert(node, for: nodeIds[id])
                    case NActivation.square:
                        node.output = Square(x: sum, response: node.activationResponse)
                        nodes.insert(node, for: nodeIds[id])
                    }
                    
                    //print("Node output: \(node.output)")
                    
                    if node.type == NType.output {
                        outputs += [node.output]
                    }
                }
            }
            //print("\nend\n")
        }
            
        /*
        if active {
            for key in self.nodes.inorderArrayFromKeys {
                var node = self.nodes.value(for: key)!
                node.output = 0
                self.nodes.remove(key)
                self.nodes.insert(node, for: node.id)
                //self.nodes[n].output = 0
            }
        }
        */
        
        /*
         if active {
         for n in 0..<self.nodes.count {
         self.nodes[n].output = 0
         }
         }
         */
        
        
        
        return outputs
    }
 
     */
    
    mutating func run(inputsIn: [Double], networkType: NetworkType) -> [Double] {
        var outputs = [Double]()
        
        var flushcount = 0
        
        if networkType == NetworkType.SnapShot {
            flushcount = getDepth()
        } else {
            flushcount = 1
        }
        
        for _ in 1...flushcount {
            
            outputs.removeAll()
            
            var cNeuron = 0
            
            for i in 1...inputsIn.count {
                var node = nodes.value(for: i)!
                node.output = inputsIn[i - 1]
                self.nodes.remove(i)
                self.nodes.insert(node, for: node.id)
                cNeuron += 1
            }
            // Setup Bias Neuron
            for i in inputsIn.count+1...inputsIn.count+1 {
                var node = nodes.value(for: i)!
                node.output = 1
                self.nodes.remove(i)
                self.nodes.insert(node, for: node.id)
                cNeuron += 1
            }
            
            while cNeuron < nodes.inorderArrayFromKeys.count {
                var sum = 0.0
                let linkKeys = self.links.inorderArrayFromKeys
                for lnk in linkKeys {
                    let link = self.links.value(for: lnk)!
                    let weight = link.weight
                    
                    // get node output from link_from_nodeID
                    let node = self.nodes.value(for: link.from)!
                    let output = node.output
                    
                    sum += weight * output
                }
                let nodeKeys = self.nodes.inorderArrayFromKeys
                var node = self.nodes.value(for: nodeKeys[cNeuron])!
                
                let type = node.activation
                switch type {
                case NActivation.sigmoid:
                    node.output = Sigmoid(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: nodeKeys[cNeuron])
                case NActivation.add:
                    node.output = Add(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: nodeKeys[cNeuron])
                case NActivation.tanh:
                    node.output = Tanh(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: nodeKeys[cNeuron])
                case NActivation.relu:
                    node.output = Relu(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: nodeKeys[cNeuron])
                case NActivation.sine:
                    node.output = Sine(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: nodeKeys[cNeuron])
                case NActivation.abs:
                    node.output = Abs(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: nodeKeys[cNeuron])
                case NActivation.square:
                    node.output = Square(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: nodeKeys[cNeuron])
                }
                
                if node.type == NType.output {
                    outputs += [node.output]
                    
                }
                cNeuron += 1
            }// Next node
            
            
            
        } ///1...flushcount
        
        
        nodeIds = self.nodes.inorderArrayFromKeys
        if networkType == NetworkType.SnapShot {
            for key in nodeIds {
                var theNode = nodes.value(for: key)!
                theNode.output = 0
                nodes.remove(theNode.id)
                nodes.insert(theNode, for: theNode.id)
            }
        }

        
        return outputs
    }
    
    private func getDepth() -> Int {
        
        var depth = 1
        
        var lowestPosition: Double = 1000000
        
        for id in nodeIds {
            let node = nodes.value(for: id)!
            if node.position.y < lowestPosition && node.position.y > 0 {
                lowestPosition = node.position.y
            }
        }
        
        // Note: '200' is used because it is the chosen maximum height of the output nodes/neurons.
        while lowestPosition < 200 {
            lowestPosition *= 2
            depth += 1
        }
        return depth
    }
    
}
