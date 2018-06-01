import Foundation

public struct NNetwork {
    
    var nodes: BTree<Int, NNode> = BTree(order: BTREEORDER)!
    var links: BTree<Int, NLink> = BTree(order: BTREEORDER)!
    
    var nodeIds = [Int]()
    
    public init(genome: NGenome) {
        
        self.links = genome.getLinks()
        
        var linksToReAdd = [NLink]()
        
        self.links.traverseKeysInOrder { key in
            var link = self.links.value(for: key)!
            if link.from == link.to {
                link.recurrent = true
                linksToReAdd += [link]
            }
        }
        
        for link in linksToReAdd {
            self.links.remove(link.innovation)
            self.links.insert(link, for: link.innovation)
        }
        
        self.nodeIds.removeAll()

        let testNodes = genome.getNodes()
        
        let _ = testNodes.map { node in
            self.nodes.insert(node, for: node.id)
        }
        
        self.links.traverseKeysInOrder { key in
            let link = self.links.value(for: key)!
            
            var fromNode = self.nodes.value(for: link.from)!
            fromNode.appendOutgoingLink(link: link)
            self.nodes.insert(fromNode, for: link.from)
            
            var toNode = self.nodes.value(for: link.to)!
            toNode.appendIncommingLink(link: link)
            self.nodes.insert(toNode, for: link.to)
        }
        
        nodeIds = self.nodes.inorderArrayFromKeys
    }
    
    public mutating func run(inputsIn: [Double], networkType: NetworkType) -> [Double] {
        var outputs = [Double]()
        
        let flushCount: Int
        
        var nodePoolIds = getNodeIdsInOrder()
        
        if networkType == .SnapShot {
            flushCount = getDepth()
        } else {
            flushCount = 1
        }
        
        for x in 1...flushCount {
            var cNeuron = 0
            
            while self.nodes.value(for: nodePoolIds[cNeuron])!.type == .input {
                //print("Is an input node")
                var node = self.nodes.value(for: nodePoolIds[cNeuron])!
                node.output = inputsIn[cNeuron]
                node.output = runActivation(activation: node.activation, x: node.output, response: node.activationResponse)
                self.nodes.remove(node.id)
                self.nodes.insert(node, for: node.id)
                cNeuron += 1
            } // End input nodes
            
            var biasNode = self.nodes.value(for: nodePoolIds[cNeuron])!
            biasNode.output = 1
            self.nodes.remove(biasNode.id)
            biasNode.output = runActivation(activation: biasNode.activation, x: biasNode.output, response: biasNode.activationResponse)
            self.nodes.insert(biasNode, for: biasNode.id)
            cNeuron += 1
            // end bias node
            
            var hiddenNode = self.nodes.value(for: nodePoolIds[cNeuron])!
            
            var tickPositions: [Double] = []
            
            while hiddenNode.type != NType.output {
                
                let nodeLinksIn = hiddenNode.incommingLinks
                
                for link in nodeLinksIn {
                    
                    if link.enabled {
                        if let nodeFrom = self.nodes.value(for: link.from) {
                            
                            if (nodeFrom.position.y == hiddenNode.position.y) || (link.from == link.to) || (nodeFrom.position.y > hiddenNode.position.y) { // They are in the same layer.
                                
                                if tickPositions.contains(hiddenNode.position.y) {
                                    
                                    //let outputWithFunction = runActivation(activation: nodeFrom.activation, x: nodeFrom.output, response: nodeFrom.activationResponse)
                                    hiddenNode.output += nodeFrom.output * link.weight
                                    hiddenNode.output = runActivation(activation: hiddenNode.activation, x: hiddenNode.output, response: hiddenNode.activationResponse)
                                    tickPositions.removeFirst()
                                    
                                } else {
                                    tickPositions += [hiddenNode.position.y]
                                }
                                
                            } else {
                                hiddenNode.output += nodeFrom.output * link.weight
                                hiddenNode.output = runActivation(activation: hiddenNode.activation, x: hiddenNode.output, response: hiddenNode.activationResponse)
                            }
                        } else {
                            fatalError()
                        }
                        
                    }
                }
                self.nodes.remove(hiddenNode.id)
                self.nodes.insert(hiddenNode, for: hiddenNode.id)
                cNeuron += 1
                hiddenNode = self.nodes.value(for: nodePoolIds[cNeuron])!
            } // End hidden nodes
            
            if x == flushCount { // Run sum up output nodes.
                while cNeuron < nodePoolIds.count {
                    var outputNode = self.nodes.value(for: nodePoolIds[cNeuron])!
                    
                    let nodeLinksIn = outputNode.incommingLinks
                    
                    for link in nodeLinksIn {
                        if link.enabled {
                            let nodeFrom = self.nodes.value(for: link.from)!
                            //let outputWithFunction = runActivation(activation: nodeFrom.activation, x: nodeFrom.output, response: nodeFrom.activationResponse)
                            outputNode.output += nodeFrom.output * link.weight
                            outputNode.output = runActivation(activation: outputNode.activation, x: outputNode.output, response: outputNode.activationResponse)
                        }
                    }
                    outputs += [outputNode.output]
                    
                    cNeuron += 1
                }
            }
        }
        return outputs
    }
    
    
    private func runActivation(activation: NActivation, x: Double, response: Double) -> Double {
        switch activation {
        case NActivation.sigmoid:
            return(Sigmoid(x: x, response: response))
        case NActivation.add:
            return(Add(x: x, response: response))
        case NActivation.tanh:
            return(Tanh(x: x, response: response))
        case NActivation.relu:
            return(Relu(x: x, response: response))
        case NActivation.sine:
            return(Sine(x: x, response: response))
        case NActivation.abs:
            return(Abs(x: x, response: response))
        case NActivation.square:
            return(Square(x: x, response: response))
        }
    }
    
    public  func getDepth() -> Int {
        //var depth = 1
        //var lowestPosition: Double = 1000000
        var nodePositions = [Double]()
        for id in nodeIds {
            /*
             let node = nodes.value(for: id)!
             if node.position.y < lowestPosition && node.position.y > 0 {
             lowestPosition = node.position.y
             
             }
             */
            let node = nodes.value(for: id)!
            nodePositions += [node.position.y]
        }
        nodePositions = sortAndRemoveDuplicates(nodePositions)
        
        return nodePositions.count - 1
    }
    
    func getNodeIdsByLayer() -> [[Int]] {
        
        var layerNodesAndPositions = [NNetworkNode]()
        
        for id in nodeIds {
            let node = self.nodes.value(for: id)!
            layerNodesAndPositions += [NNetworkNode(id: node.id, position: node.position)]
        }
        
        layerNodesAndPositions.sort()
        
        var current = 0.0
        var previous = 0.0
        
        var layerContainer = [Int]()
        
        var nodesByLayer = [[Int]]()
        
        for n in 0..<layerNodesAndPositions.count {
            
            let layerNode = layerNodesAndPositions[n]
            
            if current != previous {
                nodesByLayer += [layerContainer]
                layerContainer.removeAll()
                current = layerNode.position
            }
            
            layerContainer += [layerNode.id]
            previous = layerNode.position
        }
        
        return nodesByLayer
    }

    func getNodeIdsInOrder() -> [Int] {
        var layerNodesAndPositions = [NNetworkNode]()
        var nodeIdsToPass = [Int]()
        for id in nodeIds {
            let node = self.nodes.value(for: id)!
            layerNodesAndPositions += [NNetworkNode(id: node.id, position: node.position)]
        }
        
        layerNodesAndPositions.sort()
        for node in layerNodesAndPositions {
            nodeIdsToPass += [node.id]
        }
        return nodeIdsToPass
    }
    
}

