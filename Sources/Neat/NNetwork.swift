import Foundation

public struct NNetwork {
    
    var nodes: BTree<Int, NNode> = BTree(order: BTREEORDER)!
    var links: BTree<Int, NLink> = BTree(order: BTREEORDER)!
    
    var nodeIds = [Int]()
    
    public init(genome: NGenome) {
        
        self.links = genome.getLinks()
        
        let testNodes = genome.getNodes()
        
        for node in testNodes {
            self.nodes.insert(node, for: node.id)
            //print(node)
        }
        
        self.links.traverseKeysInOrder { key in
            let link = self.links.value(for: key)!
            
            var fromNode = self.nodes.value(for: link.from)!
            if !fromNode.outgoingLinks.contains(link) {
                let newLink = NLink(innovation: link.innovation, to: link.to, from: link.from, weight: link.weight, enabled: link.enabled, recurrent: link.recurrent)
                fromNode.appendOutgoingLink(link: newLink)
                self.nodes.insert(fromNode, for: link.from)
            }
            
            var toNode = self.nodes.value(for: link.to)!
            if !toNode.incommingLinks.contains(link) {
                let newLink = NLink(innovation: link.innovation, to: link.to, from: link.from, weight: link.weight, enabled: link.enabled, recurrent: link.recurrent)
                toNode.appendIncommingLink(link: newLink)
                self.nodes.insert(toNode, for: link.to)
            }
        }
        
        nodeIds = self.nodes.inorderArrayFromKeys
    }
    
    
    
    public mutating func run(inputsIn: [Double], networkType: NetworkType) -> [Double] {
        var outputs = [Double]()
        
        var flushcount = 0
        
        var nodePoolIds = getNodeIdsInOrder()
        
        if networkType == NetworkType.SnapShot {
            flushcount = 1
        } else {
            flushcount = 1
        }
        
        for _ in 1...flushcount {
            
            outputs.removeAll()
            
            var cNeuron = 0
            
            for _ in 1...inputsIn.count {
                var node = nodes.value(for: nodePoolIds[cNeuron])!
                node.output = inputsIn[cNeuron]
                //print("node output before: \(node.output)")
                node.output = Sigmoid(x: node.output, response: node.activationResponse)
                //print("Node output: \(node.output)")
                self.nodes.remove(node.id)
                self.nodes.insert(node, for: node.id)
                cNeuron += 1
            }
            //print("\n")
            // Setup Bias Neuron
            for _ in inputsIn.count+1...inputsIn.count+1 {
                var node = nodes.value(for: nodePoolIds[cNeuron])!
                node.output = 1.0
                //print("bias node output before: \(node.output)")
                node.output = Sigmoid(x: node.output, response: node.activationResponse)
                //print("bias Node output: \(node.output)")
                self.nodes.remove(node.id)
                self.nodes.insert(node, for: node.id)
                cNeuron += 1
            }
            
            while cNeuron < nodeIds.count {
                var sum = 0.0
                
                var node = self.nodes.value(for: nodePoolIds[cNeuron])!
                
                let incommingLinks = node.incommingLinks
                
                //print("***START***")
                for link in incommingLinks {
                    if link.enabled {
                        //print("innovation: \(link.innovation)")
                        let nodeFrom = self.nodes.value(for: link.from)!
                        //print(link.weight)
                        //print(nodeFrom.output)
                        sum += link.weight * nodeFrom.output
                        //print("\n")
                    }
                }
                //print("***END***")
                //print(sum)
                let type = node.activation
                switch type {
                case NActivation.sigmoid:
                    node.output = Sigmoid(x: sum, response: node.activationResponse)
                case NActivation.add:
                    node.output = Add(x: sum, response: node.activationResponse)
                case NActivation.tanh:
                    node.output = Tanh(x: sum, response: node.activationResponse)
                case NActivation.sine:
                    node.output = Sine(x: sum, response: node.activationResponse)
                case NActivation.abs:
                    node.output = Abs(x: sum, response: node.activationResponse)
                case NActivation.square:
                    node.output = Square(x: sum, response: node.activationResponse)
                case NActivation.cube:
                    node.output = Cube(x: sum, response: node.activationResponse)
                case NActivation.gauss:
                    node.output = Gauss(x: sum, response: node.activationResponse)
                case NActivation.hat:
                    node.output = Hat(x: sum, response: node.activationResponse)
                case NActivation.sinh:
                    node.output = Sinh(x: sum, response: node.activationResponse)
                case NActivation.sech:
                    node.output = Sech(x: sum, response: node.activationResponse)
                case NActivation.relu:
                    node.output = Relu(x: sum, response: node.activationResponse)
                case NActivation.clamped:
                    node.output = Clamped(x: sum, response: node.activationResponse)
                }
                
                nodes.remove(node.id)
                nodes.insert(node, for: node.id)
                
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
    
    public func getDescription() -> String {
        //NODE_1, Type: input, Activation: sigmoid, Activation Response: 1.30518973439587, Position: NPosition(x: 100.0, y: 0.0, z: 0.0)
        var string = ""
        self.nodes.traverseKeysInOrder { key in
            let node = self.nodes.value(for: key)!
            string += "NODE_\(node.id), Type: \(node.type), Activation: \(node.activation), Activation Response: \(node.activationResponse), Position: \(node.position)\n"
        }
        string += "\n"
        self.links.traverseKeysInOrder { key in
            let link = self.links.value(for: key)!
            string += "Innovation_\(link.innovation), [ from=\(link.from) : to=\(link.to) ], Enabled: \(link.enabled), Recurrent: \(link.recurrent), Weight: \(link.weight) --\n"
        }
        
        return string
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

