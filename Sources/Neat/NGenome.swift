import Foundation

public class NGenome {
    
    var id: Int = 0
    
    var nodes = [NNode]()
    var links: BTree<Int, NLink> = BTree(order: BTREEORDER)!
    
    var fitness = 0.0
    var adjustedFitness = 0.0
    
    init(id: Int, inputs: Int, outputs: Int, database: NDatabase) {
        self.id = id
        
        /* Genome to have all inputs plus bias connected to all outputs. */
        // Setup Input Neurons
        for i in 1...inputs {
            let position = NPosition(x: 0 + Double(i*100), y: 0, z: 0)
            let node = NNode(id: i, type: NType.input, position: position, activation: NActivation.sigmoid)
            nodes += [node]
            //let _ = database.newInnovation(node: node, link: nil)
        }
        // Setup Bias Neuron
        for i in inputs+1...inputs+1 {
            BIASID = i
            let position = NPosition(x: -100, y: 0, z: 0)
            let node = NNode(id: i, type: NType.bias, position: position, activation: NActivation.relu)
            nodes += [node]
            //let _ = database.newInnovation(node: node, link: nil)
        }
        // Setup Output Neurons
        for i in (inputs+2)...(outputs+inputs+1) {
            let position = NPosition(x: Double(inputs)*25, y: 200, z: 0)
            let node = NNode(id: i, type: NType.output, position: position, activation: NActivation.sigmoid)
            nodes += [node]
            //let _ = database.newInnovation(node: node, link: nil)
        }
        
        /* Genome's initial nodes to be connected via links */
        var linkId = 1
        for i in 1...(inputs + 1) {
            for o in (inputs + 2)...(outputs + inputs + 1) {
                let link = NLink(innovation: linkId, to: o, from: i)
                //links += [link]
                
                links.insert(link, for: link.innovation)
                nodes[i-1].outgoingLinks += [NLink(innovation: linkId, to: o, from: i)]
                nodes[o-1].incommingLinks += [NLink(innovation: linkId, to: o, from: i)]
                let _ = database.newInnovation(node: nil, link: link)
                linkId += 1
            }
        }
    }
    
    init(id: Int, nodes: [NNode], links: BTree<Int, NLink>, fitness: Double) {
        self.id = id
        self.nodes = nodes
        /*
         var newNodes = [NNode]()
         for node in 0..<nodes.count {
         newNodes += [nodes[node]]
         let nodee = newNodes[node]
         if nodee.type != NType.output && nodee.type != NType.input && nodee.type != NType.bias  {
         newNodes[node].activation = NRandomActivationType()
         }
         
         }
         self.nodes = newNodes
         */
        self.links = links
        self.fitness = fitness
    }
    
    init() { }
    
    func nodeCount() -> Int { return self.nodes.count }
    
    func getNodes() -> [NNode] { return self.nodes }
    
    func getLinks() -> BTree<Int, NLink> { return self.links }
    
    // MARK: Mutation
    func mutate(database: NDatabase) {
        
        if normalRandom() <= database.perturbMutation {
            // mutate weights
            perturbWeights(database: database)
        }
        if normalRandom() <= database.addNodeMutation {
            // add node
            addNode(database: database)
        }
        if normalRandom() <= database.addLinkMutation {
            // add link
            addLink(database: database)
        }
        if normalRandom() <= database.enableMutation {
            // change enable
            changeEnable()
        }
        if normalRandom() <= database.activationMutation {
            // perturb activation response
            perturbActivationResponse(perturbAmount: database.activationPerturbAmount)
        }
        if normalRandom() <= database.typeMutation {
            changeType()
        }
        
    }
    
    private func perturbWeights(database: NDatabase) {
        let linkKeys = self.links.inorderArrayFromKeys
        let perturbAmount = database.perturbAmount
        /*
         if normalRandom() <= 0.5 {
         perturbAmount *= -1
         }
         */
        if normalRandom() <= 0.5 {
            for key in linkKeys {
                var link = links.value(for: key)!
                if link.from != BIASID {
                    if normalRandom() <= 0.9 {
                        self.links.remove(key)
                        //print("Old link value: \(newLink.weight)")
                        link.perturbWeight(amount: perturbAmount)
                        //print("New link value: \(newLink.weight)")
                        self.links.insert(link, for: link.innovation)
                    } else {
                        self.links.remove(key)
                        //print("Old link value: \(newLink.weight)")
                        link.weight = NRandom()
                        //print("New link value: \(newLink.weight)")
                        self.links.insert(link, for: link.innovation)
                    }
                    
                }
            }
        } else {
            for key in linkKeys {
                var link = links.value(for: key)!
                if link.from != BIASID {
                    if normalRandom() <= 0.9 {
                        self.links.remove(key)
                        //print("Old link value: \(newLink.weight)")
                        link.perturbWeight(amount: -perturbAmount)
                        //print("New link value: \(newLink.weight)")
                        self.links.insert(link, for: link.innovation)
                    } else {
                        self.links.remove(key)
                        //print("Old link value: \(newLink.weight)")
                        link.weight = NRandom()
                        //print("New link value: \(newLink.weight)")
                        self.links.insert(link, for: link.innovation)
                    }
                    
                }
            }
        }
        
        
        
    }
    
    private func perturbActivationResponse(perturbAmount: Double) {
        
        var tempPerturbAmount = perturbAmount
        
        if normalRandom() <= 0.5 {
            tempPerturbAmount *= -1
        }
        
        var killSwitch = 15
        for _ in 1...self.nodes.count {
            var randNodeId = randomInt(min: 0, max: self.nodes.count)
            //while nodes[randNodeId].type == NType.input || nodes[randNodeId].type == NType.bias || nodes[randNodeId].type == NType.output {
            while nodes[randNodeId].type == NType.bias {
                if killSwitch <= 0 { return }
                randNodeId = randomInt(min: 0, max: self.nodes.count)
                killSwitch -= 1
                
            }
            //self.nodes[randNodeId].activationResponse += tempPerturbAmount
            
            if nodes[randNodeId].type != NType.bias {
                self.nodes[randNodeId].activationResponse = abs(tempPerturbAmount)
            }
            killSwitch = 15
        }
    }
    
    private func changeType() {
        
        var randIndex = randomInt(min: 0, max: nodes.count)
        var killer = 10
        while self.nodes[randIndex].type == NType.input || self.nodes[randIndex].type == NType.bias || self.nodes[randIndex].type == NType.output {
            if killer <= 0 { return }
            randIndex = randomInt(min: 0, max: nodes.count)
            killer -= 1
        }
    }
    
    private func changeEnable() {
        
        let linkKeys = self.links.inorderArrayFromKeys
        //let newLinks: BTree<Int, NLink> = BTree(order: BTREEORDER)!
        
        for _ in nodes {
            var randomId = randomInt(min: 0, max: linkKeys.count)
            var daLink = links.value(for: linkKeys[randomId])!
            /*
             var killer = 10
             
             while daLink.enabled {
             randomId = randomInt(min: 0, max: linkKeys.count)
             daLink = links.value(for: linkKeys[randomId])!
             killer -= 1
             if killer <= 0 { break }
             }
             */
            daLink.enabled = !daLink.enabled
            self.links.remove(linkKeys[randomId])
            self.links.insert(daLink, for: daLink.innovation)
        }
        
        
        /*
         for key in linkKeys {
         let link = links.value(for: key)!
         var newLink = NLink(innovation: link.innovation, to: link.to, from: link.from, weight: link.weight, enabled: link.enabled, recurrent: link.recurrent)
         if normalRandom() <= 0.8 {
         newLink.enable()
         links.remove(key)
         newLinks.insert(newLink, for: newLink.innovation)
         } else {
         newLink.disable()
         links.remove(key)
         newLinks.insert(newLink, for: newLink.innovation)
         }
         }
         */
        //self.links = newLinks
    }
    
    private func addNode(database: NDatabase) {
        
        // Find a random link to be split
        let linkKeys = self.links.inorderArrayFromKeys
        
        
        var randomLinkKeyIndex = randomInt(min: 0, max: linkKeys.count)
        var linkToSplit = self.links.value(for: linkKeys[randomLinkKeyIndex])!
        
        var killer = 10
        while linkToSplit.recurrent || linkToSplit.from == database.biasId {
            if killer <= 0 { return }
            randomLinkKeyIndex = randomInt(min: 0, max: linkKeys.count)
            linkToSplit = self.links.value(for: linkKeys[randomLinkKeyIndex])!
            killer -= 1
        }
        
        linkToSplit.disable()
        self.links.remove(linkToSplit.innovation)
        self.links.insert(linkToSplit, for: linkToSplit.innovation)
        
        let linkData = database.getLinkDataFromComparison(nodeFrom: linkToSplit.from, nodeTo: linkToSplit.to)
        
        var nodeAPos: NPosition = NPosition(x: 0, y: 0, z: 0)
        var nodeBPos: NPosition = NPosition(x: 0, y: 0, z: 0)
        
        for node in self.nodes {
            if node.id == linkToSplit.to {
                nodeAPos = node.position
            }
            if node.id == linkToSplit.from {
                nodeBPos = node.position
            }
        }
        
        var newNode: NNode = NNode(id: -1)
        let newNodePosition = NPosition(x: (nodeAPos.x + nodeBPos.x) / 2, y: (nodeAPos.y + nodeBPos.y) / 2, z: (nodeAPos.y + nodeBPos.y) * 2)
        //print("Link data: \(linkData)")
        if linkData.isEmpty { // No node exists so create an entirely new one
            newNode = NNode(id: database.nextNodeId(), type: NType.hidden, position: newNodePosition, activation: NRandomActivationType())
            // Also, no connections exist so create new connections below...
            var linkA = NLink(innovation: database.nextInnovation(), to: newNode.id, from: linkToSplit.from)
            linkA.weight = 1
            
            database.insertLink(link: linkA)
            var linkB = NLink(innovation: database.nextInnovation(), to: linkToSplit.to, from: newNode.id)
            linkB.weight = linkToSplit.weight
            database.insertLink(link: linkB)
            
            newNode.incommingLinks += [linkA]
            newNode.outgoingLinks += [linkB]
            
            self.links.insert(linkA, for: linkA.innovation)
            self.links.insert(linkB, for: linkB.innovation)
            
            
        } else { // links already exist with a node given in linkData
            newNode = NNode(id: linkData.first!, type: NType.hidden, position: newNodePosition, activation: NRandomActivationType())
            // Therefore, add the links that exist into this genome below...
            //print("linkData: \(linkData.first!)")
            let linkAId = database.getInnovationId(from: linkToSplit.from, to: linkData.first!)
            //linkA.weight = 1
            //print("linkA: \(linkToSplit.from):\(linkData.first!)")
            let linkBId = database.getInnovationId(from: linkData.first!, to: linkToSplit.to)
            //print("linkB: \(linkData.first!):\(linkToSplit.to)")
            if (linkAId == -1) || (linkBId == -1) { fatalError() }
            var linkA = NLink(innovation: linkAId, to: linkData.first!, from: linkToSplit.from)
            linkA.weight = 1
            var linkB = NLink(innovation: linkBId, to: linkToSplit.to, from: linkData.first!)
            linkB.weight = linkToSplit.weight
            
            newNode.incommingLinks += [linkA]
            newNode.outgoingLinks += [linkB]
            
            self.links.insert(linkA, for: linkAId)
            self.links.insert(linkB, for: linkBId)
        }
        //print(newNode.position)
        self.nodes += [newNode]
    }
    
    private func addLink(database: NDatabase) {
        /* If there are no hidden nodes, then do not make a connection */
        // Check if there are hidden nodes, and if there are skip
        // Additionally, gather hidden nodes and output nodes identifiers.
        var hiddenNodesExist = false
        var inputNodeIds = [Int]()
        var hiddenNodeIds = [Int]()
        var outputNodeIds = [Int]()
        for node in self.nodes {
            // find if hidden nodes exist
            if node.type == NType.hidden {
                hiddenNodesExist = true
                hiddenNodeIds += [node.id]
            } else if node.type == NType.input {
                inputNodeIds += [node.id]
            } else if node.type == NType.output {
                outputNodeIds += [node.id]
            }
        }
        let inputHiddenIds = inputNodeIds + hiddenNodeIds
        let hiddenOutputIds = hiddenNodeIds + outputNodeIds
        if hiddenNodesExist { // Hidden nodes exist, so try and find a connection if possible.
            // The incomming nodes will be the input nodes and hidden nodes
            // The outgoing nodes will be the hidden and the output nodes.
            for _ in 1...Int(database.timesToFindConnection) { // timesToFindConnection to be > 0 obviously
                let randInId = randomInt(min: 0, max: inputNodeIds.count)
                let randOutId = randomInt(min: 0, max: hiddenOutputIds.count)
                if outputNodeIds.contains(randInId) && (randOutId == randInId) { continue }
                let toId = hiddenOutputIds[randOutId]
                let fromId = inputHiddenIds[randInId]
                
                let potentialInnovationId = database.getInnovationId(from: fromId, to: toId)
                
                if potentialInnovationId != -1 { // Innovation already exists
                    // Check if this already exists in this genome
                    if self.links.value(for: potentialInnovationId) != nil { // Link does exist, so continue.
                        continue
                    }
                    // Link does not exist in this genome but does exist globally
                    var newLink = NLink(innovation: potentialInnovationId, to: toId, from: fromId)
                    
                    if toId == fromId {
                        newLink.isRecurrent(isRecurrent: true)
                    }
                    
                    var nCheck = 0
                    for node in 0..<self.nodes.count {
                        if self.nodes[node].id == toId {
                            self.nodes[node].incommingLinks += [newLink]
                            nCheck += 1
                        } else if self.nodes[node].id == fromId {
                            self.nodes[node].outgoingLinks += [newLink]
                            nCheck += 1
                        }
                        if nCheck > 1 { break }
                    }
                    
                    self.links.insert(newLink, for: potentialInnovationId)
                    //print("Old Link: \(newLink.from):\(newLink.to)")
                    break
                    
                } else { // innovation does not exist (assuming that it doesn't exist globally and in this genome)
                    // Create a new link for the database and this genome.
                    var newLink = NLink(innovation: database.nextInnovation(), to: toId, from: fromId)
                    
                    if toId == fromId {
                        newLink.isRecurrent(isRecurrent: true)
                    }
                    
                    var nCheck = 0
                    for node in 0..<self.nodes.count {
                        if self.nodes[node].id == toId {
                            self.nodes[node].incommingLinks += [newLink]
                            nCheck += 1
                        } else if self.nodes[node].id == fromId {
                            self.nodes[node].outgoingLinks += [newLink]
                            nCheck += 1
                        }
                        if nCheck > 1 { break }
                    }
                    
                    self.links.insert(newLink, for: newLink.innovation)
                    database.insertLink(link: newLink)
                    //print("New Link: \(newLink.from):\(newLink.to)")
                    break
                }
            }
            
        } else { // else skip trying to find a connection (maybe add a node instead?)
            self.addNode(database: database) // May remove this line.
        }
    }
    
}

// MARK: Custom
// Get the genome's link's innovation numbers in order
extension NGenome {
    
    func getInnovations(database: NDatabase) -> [Int] {
        var innovationIds = [Int]()
        /*
         for linkId in self.links.inorderArrayFromKeys {
         innovationIds += [database.getInnovationId(link: links.value(for: linkId)!)]
         }
         */
        self.links.traverseKeysInOrder { key in
            innovationIds += [database.getInnovationId(link: links.value(for: key)!)]
        }
        
        return innovationIds
    }
    
}

extension NGenome: Comparable {
    public static func < (lhs: NGenome, rhs: NGenome) -> Bool {
        return lhs.fitness > rhs.fitness
    }
    
    public static func == (lhs: NGenome, rhs: NGenome) -> Bool {
        return lhs.fitness == rhs.fitness
    }
}

// Copy the Genome
extension NGenome {
    func copy() -> NGenome {
        
        let newLinks: BTree<Int, NLink> = BTree(order: BTREEORDER)!
        
        self.links.traverseKeysInOrder { key in
            let link = self.links.value(for: key)!
            newLinks.insert(link, for: key)
        }
        /*
         let linkKeys = self.links.inorderArrayFromKeys
         for key in linkKeys {
         let link = self.links.value(for: key)!
         newLinks.insert(link, for: link.innovation)
         }
         */
        return NGenome(id: self.id, nodes: self.nodes, links: newLinks, fitness: self.fitness)
    }
}


// MARK: NGenome extension: Decription

extension NGenome: CustomStringConvertible {
    /**
     *  Returns details of the network
     */
    public var description: String {
        var s = ""
        var n = "\n"
        var l = "\n"
        let nodes = self.getNodes()
        for node in nodes {
            n += "NODE_\(node.id), Type: \(node.type), Activation: \(node.activation), Activation Response: \(node.activationResponse)\n"
        }
        //let linkKeys = self.links.inorderArrayFromKeys
        
        self.links.traverseKeysInOrder { key in
            let theLink = self.links.value(for: key)!
            l += "Innovation_\(theLink.innovation), [ \(theLink.from):\(theLink.to) ], Enabled: \(theLink.enabled), Recurrent: \(theLink.recurrent), Weight: \(theLink.weight)\n"
        }
        /*
         for key in linkKeys {
         let theLink = self.links.value(for: key)!
         l += "Innovation_\(theLink.innovation), [ \(theLink.from):\(theLink.to) ], Enabled: \(theLink.enabled), Recurrent: \(theLink.recurrent), Weight: \(theLink.weight)\n"
         }
         */
        
        s += "\n    Genome_\(self.id),\n\n    fitness: \(self.fitness)\n"
        return s + n + l
    }
}
