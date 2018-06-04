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
        
        /*
         for node in genome.getNodes() {
         self.nodes.insert(node, for: node.id)
         }
         */
        let testNodes = genome.getNodes()
        
        let _ = testNodes.map { node in
            self.nodes.insert(node, for: node.id)
        }
        //print(self.nodes)
        
        self.links.traverseKeysInOrder { key in
            let link = self.links.value(for: key)!
            
            var fromNode = self.nodes.value(for: link.from)!
            fromNode.appendOutgoingLink(link: link)
            self.nodes.insert(fromNode, for: link.from)
            
            var toNode = self.nodes.value(for: link.to)!
            toNode.appendIncommingLink(link: link)
            self.nodes.insert(toNode, for: link.to)
        }
        
        /*
         
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
         */
        
        nodeIds = self.nodes.inorderArrayFromKeys
    }
    
    
    
    public mutating func run(inputsIn: [Double], networkType: NetworkType) -> [Double] {
        var outputs = [Double]()
        
        var flushcount = 0
        
        var nodePoolIds = getNodeIdsInOrder()
        
        if networkType == NetworkType.SnapShot {
            flushcount = getDepth()
        } else {
            flushcount = 1
        }
        
        for _ in 1...flushcount {
            
            outputs.removeAll()
            
            var cNeuron = 0
            
            for i in 1...inputsIn.count {
                var node = nodes.value(for: nodePoolIds[i - 1])!
                node.output = inputsIn[i - 1]
                //node.output = Sigmoid(x: node.output, response: node.activationResponse)
                self.nodes.remove(nodePoolIds[i - 1])
                self.nodes.insert(node, for: node.id)
                cNeuron += 1
            }
            // Setup Bias Neuron
            for i in inputsIn.count+1...inputsIn.count+1 {
                var node = nodes.value(for: nodePoolIds[i - 1])!
                node.output = 1
                //node.output = Sigmoid(x: node.output, response: node.activationResponse)
                self.nodes.remove(nodePoolIds[i - 1])
                self.nodes.insert(node, for: node.id)
                cNeuron += 1
            }
            
            while cNeuron < nodeIds.count {
                var sum = 0.0
                
                var node = self.nodes.value(for: nodePoolIds[cNeuron])!
                
                let incommingLinks = node.incommingLinks
                
                
                for link in incommingLinks {
                    let nodeFrom = self.nodes.value(for: link.from)!
                    sum += link.weight * nodeFrom.output
                }
                /*
                 self.links.traverseKeysInOrder { key in
                 let link = self.links.value(for: key)!
                 let weight = link.weight
                 
                 // get node output from link_from_nodeID
                 let node = self.nodes.value(for: link.from)!
                 let output = node.output
                 
                 sum += weight * output
                 }
                 */
                let type = node.activation
                switch type {
                case NActivation.sigmoid:
                    node.output = Sigmoid(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: nodePoolIds[cNeuron])
                case NActivation.add:
                    node.output = Add(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: nodePoolIds[cNeuron])
                case NActivation.tanh:
                    node.output = Tanh(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: nodePoolIds[cNeuron])
                case NActivation.relu:
                    node.output = Relu(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: nodePoolIds[cNeuron])
                case NActivation.sine:
                    node.output = Sine(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: nodePoolIds[cNeuron])
                case NActivation.abs:
                    node.output = Abs(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: nodePoolIds[cNeuron])
                case NActivation.square:
                    node.output = Square(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: nodePoolIds[cNeuron])
                default:
                    node.output = Sine(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: nodePoolIds[cNeuron])
                }
                
                if node.type == NType.output {
                    outputs += [node.output]
                }
                cNeuron += 1
            }// Next node
            
            if networkType == NetworkType.SnapShot {
                for key in nodeIds {
                    var theNode = nodes.value(for: key)!
                    theNode.output = 0
                    nodes.remove(theNode.id)
                    nodes.insert(theNode, for: theNode.id)
                }
            }
            
        } ///1...flushcount
        
        return outputs
    }
    
    
    /*
     public mutating func run(inputsIn: [Double], networkType: NetworkType) -> [Double] {
     var outputs = [Double]()
     
     let flushCount: Int
     
     var nodePoolIds = getNodeIdsInOrder()
     
     if networkType == .SnapShot {
     flushCount = getDepth()
     } else {
     flushCount = 1
     }
     
     // get layer positions
     let layerPositions = getLayerPositions()
     
     var timer = 1
     
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
     
     while hiddenNode.type != NType.output {
     
     let nodeLinksIn = hiddenNode.incommingLinks
     for link in nodeLinksIn {
     
     if link.enabled {
     
     let nodeFrom = self.nodes.value(for: link.from)!
     if hiddenNode.tick == 1 {
     if link.from == link.to || hiddenNode.position.y == nodeFrom.position.y {
     
     // find this node's layer number
     var layerID = 1
     
     for layer in 0..<layerPositions.count {
     if hiddenNode.position.y == layerPositions[layer] {
     break
     }
     layerID += 1
     }
     //print("Current Layer: \(layerID), Current tick: \(timer)")
     hiddenNode.tick = layerID
     
     } else {
     hiddenNode.output += nodeFrom.output
     hiddenNode.output = runActivation(activation: hiddenNode.activation, x: hiddenNode.output, response: hiddenNode.activationResponse)
     hiddenNode.output *= link.weight
     }
     } else if hiddenNode.tick == timer {
     hiddenNode.output += nodeFrom.output
     hiddenNode.output = runActivation(activation: hiddenNode.activation, x: hiddenNode.output, response: hiddenNode.activationResponse)
     hiddenNode.output *= link.weight
     for link in hiddenNode.outgoingLinks {
     if link.enabled {
     var nodeTo = self.nodes.value(for: link.to)!
     
     nodeTo.output += runActivation(activation: hiddenNode.activation, x: hiddenNode.output * link.weight, response: hiddenNode.activationResponse)
     nodeTo.tick = timer + 1
     self.nodes.remove(nodeTo.id)
     self.nodes.insert(nodeTo, for: nodeTo.id)
     }
     }
     } else { // A recurrent link was found before other regular links
     hiddenNode.output += nodeFrom.output
     hiddenNode.output = runActivation(activation: hiddenNode.activation, x: hiddenNode.output, response: hiddenNode.activationResponse)
     hiddenNode.output *= link.weight
     }
     }
     }
     
     self.nodes.remove(hiddenNode.id)
     self.nodes.insert(hiddenNode, for: hiddenNode.id)
     cNeuron += 1
     timer += 1
     hiddenNode = self.nodes.value(for: nodePoolIds[cNeuron])!
     } // End hidden nodes
     
     if x == flushCount { // Run sum up output nodes.
     while cNeuron < nodePoolIds.count {
     var outputNode = self.nodes.value(for: nodePoolIds[cNeuron])!
     //outputNode.output = 0.0
     
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
     */
    
    private func runActivation(activation: NActivation, x: Double, response: Double) -> Double {
        switch activation {
        case NActivation.sigmoid:
            return Sigmoid(x: x, response: response)
        case NActivation.add:
            return Add(x: x, response: response)
        case NActivation.tanh:
            return Tanh(x: x, response: response)
        case NActivation.relu:
            return Relu(x: x, response: response)
        case NActivation.sine:
            return Sine(x: x, response: response)
        case NActivation.abs:
            return Abs(x: x, response: response)
        case NActivation.square:
            return Square(x: x, response: response)
        case NActivation.cube:
            //return Cube(x: x, response: response)
            return Sine(x: x, response: response)
        case NActivation.exp:
            //return Exp(x: x, response: response)
            return Sine(x: x, response: response)
        case NActivation.guass:
            return Gauss(x: x, response: response)
        case NActivation.clamped:
            return Clamped(x: x, response: response)
        case NActivation.hat:
            return Hat(x: x, response: response)
        case NActivation.log:
            //return Log(x: x, response: response)
            return Sine(x: x, response: response)
        case NActivation.softRElu:
            return SoftReLU(x: x, response: response)
        case NActivation.sinh:
            return Sinh(x: x, response: response)
        case NActivation.sech:
            //return Sech(x: x, response: response)
            return Sine(x: x, response: response)
        }
    }
    
    public func getDepth() -> Int {
        //var depth = 1
        //var lowestPosition: Double = 1000000
        var nodePositions = [Double]()
        for id in nodeIds {
            let node = nodes.value(for: id)!
            nodePositions += [node.position.y]
        }
        nodePositions = sortAndRemoveDuplicates(nodePositions)
        
        return nodePositions.count - 1
    }
    
    public func getLayerPositions() -> [Double] {
        var nodePositions = [Double]()
        for id in nodeIds {
            let node = nodes.value(for: id)!
            nodePositions += [node.position.y]
        }
        nodePositions = sortAndRemoveDuplicates(nodePositions)
        return nodePositions
    }
    
    /*
     public mutating func run(inputsIn: [Double], networkType: NetworkType) -> [Double] {
     var outputs = [Double]()
     
     let nodeIdsByLayer = self.getNodeIdsByLayer()
     
     var inputCounter = 0
     for layer in nodeIdsByLayer {
     for nodeId in layer {
     var node = self.nodes.value(for: nodeId)!           // GET NODE
     if node.type == NType.input {
     node.output = inputsIn[inputCounter]            // ADD INPUT TO INPUT NODES
     inputCounter += 1
     } else if node.type == NType.hidden {
     node.output +=
     }
     }
     }
     
     return outputs
     }
     
     */
    
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

