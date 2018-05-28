import Foundation

public struct NNetwork {
    
    var nodes: BTree<Int, NNode> = BTree(order: BTREEORDER)!
    var links: BTree<Int, NLink> = BTree(order: BTREEORDER)!
    
    var nodeIds = [Int]()
    
    public init(genome: NGenome) {
        
        self.links = genome.getLinks()
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
    
    /*
     
     public mutating func run(inputsIn: [Double], networkType: NetworkType) -> [Double] {
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
     
     while cNeuron < nodeIds.count {
     var sum = 0.0
     
     self.links.traverseKeysInOrder { key in
     
     let link = self.links.value(for: key)!
     if link.enabled {
     let weight = link.weight
     
     // get node output from link_from_nodeID
     let node = self.nodes.value(for: link.from)!
     let output = node.output
     
     sum += weight * output
     }
     
     }
     
     var node = self.nodes.value(for: nodeIds[cNeuron])!
     
     let type = node.activation
     switch type {
     case NActivation.sigmoid:
     node.output = Sigmoid(x: sum, response: node.activationResponse)
     case NActivation.add:
     node.output = Add(x: sum, response: node.activationResponse)
     case NActivation.tanh:
     node.output = Tanh(x: sum, response: node.activationResponse)
     case NActivation.relu:
     node.output = Relu(x: sum, response: node.activationResponse)
     case NActivation.sine:
     node.output = Sine(x: sum, response: node.activationResponse)
     case NActivation.abs:
     node.output = Abs(x: sum, response: node.activationResponse)
     case NActivation.square:
     node.output = Square(x: sum, response: node.activationResponse)
     }
     
     nodes.remove(node.id)
     nodes.insert(node, for: nodeIds[cNeuron])
     
     if node.type == NType.output {
     outputs += [node.output]
     }
     cNeuron += 1
     }// Next node
     
     
     
     } ///1...flushcount
     /*
     if networkType == NetworkType.SnapShot {
     self.nodes.traverseKeysInOrder { key in
     var theNode = nodes.value(for: key)!
     theNode.output = 0
     nodes.remove(theNode.id)
     nodes.insert(theNode, for: theNode.id)
     }
     }
     */
     
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
     
     */
    
    public mutating func run(inputsIn: [Double], networkType: NetworkType) -> [Double] {
        var outputs = [Double]()
        
        let flushCount: Int
        
        var nodePoolIds = getNodeIdsInOrder()
        
        if networkType == .SnapShot {
            flushCount = getDepth()
        } else {
            flushCount = 1
        }
        
        
        for _ in 1...flushCount {
            outputs.removeAll()
            
            var cNeuron = 0
            
            while self.nodes.value(for: nodePoolIds[cNeuron])!.type == .input {
                var node = self.nodes.value(for: nodePoolIds[cNeuron])!
                node.output = inputsIn[cNeuron]
                self.nodes.remove(node.id)
                self.nodes.insert(node, for: node.id)
                cNeuron += 1
            }
            
            var biasNode = self.nodes.value(for: nodePoolIds[cNeuron])!
            biasNode.output = 1
            self.nodes.remove(biasNode.id)
            self.nodes.insert(biasNode, for: biasNode.id)
            cNeuron += 1
            
            while cNeuron < nodePoolIds.count {
                var sum = 0.0
                
                var node = self.nodes.value(for: nodePoolIds[cNeuron])!
                let nodeLinks = node.incommingLinks
                for link in nodeLinks {
                    if link.enabled {
                        let output = self.nodes.value(for: link.from)!.output
                        
                        sum += output * link.weight
                    }
                    
                }
                
                let type = node.activation
                switch type {
                case NActivation.sigmoid:
                    node.output = Sigmoid(x: sum, response: node.activationResponse)
                case NActivation.add:
                    node.output = Add(x: sum, response: node.activationResponse)
                case NActivation.tanh:
                    node.output = Tanh(x: sum, response: node.activationResponse)
                case NActivation.relu:
                    node.output = Relu(x: sum, response: node.activationResponse)
                case NActivation.sine:
                    node.output = Sine(x: sum, response: node.activationResponse)
                case NActivation.abs:
                    node.output = Abs(x: sum, response: node.activationResponse)
                case NActivation.square:
                    node.output = Square(x: sum, response: node.activationResponse)
                }
                
                nodes.remove(nodePoolIds[cNeuron])
                nodes.insert(node, for: nodePoolIds[cNeuron])
                
                if node.type == .output {
                    outputs += [node.output]
                }
                
                cNeuron += 1
            }
        }
        
        return outputs
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
        
        /*
         print(nodePositions)
         
         // Note: '200' is used because it is the chosen maximum height of the output nodes/neurons.
         while lowestPosition < 200 {
         lowestPosition *= 2
         depth += 1
         }
         //print("depth: \(depth)")
         */
        return nodePositions.count - 1
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

