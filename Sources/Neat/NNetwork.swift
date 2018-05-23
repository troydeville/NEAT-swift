import Foundation

public struct NNetwork {
    
    var nodes: BTree<Int, NNode> = BTree(order: BTREEORDER)!
    var links: BTree<Int, NLink> = BTree(order: BTREEORDER)!
    
    var nodeIds = [Int]()
    
    public init(genome: NGenome) {
        
        self.links = genome.getLinks()
        self.nodeIds.removeAll()
        
        for node in genome.getNodes() {
            self.nodes.insert(node, for: node.id)
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
    }
    
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
    
    public  func getDepth() -> Int {
        
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
