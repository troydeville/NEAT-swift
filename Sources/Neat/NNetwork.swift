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
        }
        
        self.links.traverseKeysInOrder { key in
            let link = self.links.value(for: key)!
            
            var fromNode = self.nodes.value(for: link.from)!
            if !fromNode.outgoingLinks.contains(link) {
                fromNode.appendOutgoingLink(link: link)
                self.nodes.insert(fromNode, for: link.from)
            }
            
            var toNode = self.nodes.value(for: link.to)!
            if !toNode.incommingLinks.contains(link) {
                toNode.appendIncommingLink(link: link)
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
                node.output = Sigmoid(x: node.output, response: node.activationResponse)
                self.nodes.remove(nodePoolIds[i - 1])
                self.nodes.insert(node, for: node.id)
                cNeuron += 1
            }
            // Setup Bias Neuron
            for i in inputsIn.count+1...inputsIn.count+1 {
                var node = nodes.value(for: nodePoolIds[i - 1])!
                node.output = 1
                node.output = Sigmoid(x: node.output, response: node.activationResponse)
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
                    nodes.insert(node, for: node.id)
                case NActivation.add:
                    node.output = Add(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: node.id)
                case NActivation.tanh:
                    node.output = Tanh(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: node.id)
                case NActivation.sine:
                    node.output = Sine(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: node.id)
                case NActivation.abs:
                    node.output = Abs(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: node.id)
                case NActivation.square:
                    node.output = Square(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: node.id)
                case NActivation.cube:
                    node.output = Cube(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: node.id)
                case NActivation.gauss:
                    node.output = Gauss(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: node.id)
                case NActivation.hat:
                    node.output = Hat(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: node.id)
                case NActivation.sinh:
                    node.output = Sinh(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: node.id)
                case NActivation.sech:
                    node.output = Sech(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: node.id)
                case NActivation.relu:
                    node.output = Relu(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: node.id)
                case NActivation.clamped:
                    node.output = Clamped(x: sum, response: node.activationResponse)
                    nodes.remove(node.id)
                    nodes.insert(node, for: node.id)
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
    
    public func getDepth() -> Int {
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

