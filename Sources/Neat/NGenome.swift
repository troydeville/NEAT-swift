import Foundation

public class NGenome {
    
    public var id: Int = 0
    
    public var nodes = [NNode]()
    public var links: BTree<Int, NLink> = BTree(order: BTREEORDER)!
    
    public var fitness = 0.0
    public var adjustedFitness = 0.0
    
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
            let node = NNode(id: i, type: NType.bias, position: position, activation: NActivation.sigmoid)
            nodes += [node]
        }
        // Setup Output Neurons
        for i in (inputs+2)...(outputs+inputs+1) {
            let position = NPosition(x: Double(inputs)*25, y: 200, z: 0)
            let node = NNode(id: i, type: NType.output, position: position, activation: NActivation.sigmoid)
            nodes += [node]
        }
        
        /* Genome's initial nodes to be connected via links */
        var linkId = 1
        for i in 1...(inputs + 1) {
            for o in (inputs + 2)...(outputs + inputs + 1) {
                let link = NLink(innovation: linkId, to: o, from: i)
                
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
        
        self.links = links
        
        var linksToMakeRecurrent: [Int] = []
        
        links.traverseKeysInOrder { key in
            let link = links.value(for: key)!
            if link.from == link.to {
                linksToMakeRecurrent += [key]
            }
        }
        
        for key in linksToMakeRecurrent {
            var link = self.links.value(for: key)!
            link.recurrent = true
            self.links.remove(key)
            self.links.insert(link, for: key)
        }

        self.fitness = fitness
    }
    
    init() { }
    
    func nodeCount() -> Int { return self.nodes.count }
    
    func getNodes() -> [NNode] { return self.nodes }
    
    func getLinks() -> BTree<Int, NLink> {
        
        let linksToBe = BTree<Int, NLink>(order: BTREEORDER)!
        
        self.links.traverseKeysInOrder { key in
            let link = self.links.value(for: key)!
            linksToBe.insert(link, for: key)
        }
        
        return linksToBe
    }
    
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
        if normalRandom() <= database.typeMutation {
            changeType()
        }
        if normalRandom() <= database.addLinkMutation {
            // add link
            addLink(database: database)
        }
        
        // Not implemented in this version.
        /*
        if normalRandom() <= database.removeLinkMutation {
            // remove link
            //removeLink()
        }
        */
        
        if normalRandom() <= database.enableMutation {
            // change enable
            enableLink(database: database)
        } else if normalRandom() <= database.disableMutation {
            disableLink(database: database)
        }
        if normalRandom() <= database.activationMutation {
            // perturb activation response
            perturbActivationResponse(perturbAmount: database.activationPerturbAmount)
        }
        
        
    }
    
    private func perturbWeights(database: NDatabase) {
        let linkKeys = self.links.inorderArrayFromKeys
        let perturbAmount = database.perturbMutation
        for key in linkKeys {
            var link = self.links.value(for: key)!
            if normalRandom() <= 0.5 {
                link.weight += perturbAmount
            } else {
                link.weight -= perturbAmount
            }
            self.links.remove(key)
            self.links.insert(link, for: key)
        }
    }
    
    private func perturbActivationResponse(perturbAmount: Double) {
        
        if normalRandom() <= 0.5 {
            let nodeId = randomInt(min: 0, max: self.nodes.count)
            var node = self.nodes[nodeId]
            if node.type != NType.bias {
                node.activationResponse += perturbAmount * normalRandom()
                self.nodes[nodeId] = node
            }
        } else {
            let nodeId = randomInt(min: 0, max: self.nodes.count)
            var node = self.nodes[nodeId]
            if node.type != NType.bias {
                node.activationResponse -= perturbAmount * normalRandom()
                self.nodes[nodeId] = node
            }
        }
    }
    
    private func changeType() {
        
        var iRand = randomInt(min: 0, max: self.nodes.count)
        var node = self.nodes[iRand]
        var ccc = 10
        
        while ccc > 0 {
            
            if node.type != NType.input && node.type != NType.bias && node.type != NType.output {
                self.nodes[iRand].activation = NRandomActivationType()
                break
            }
            
            iRand = randomInt(min: 0, max: self.nodes.count)
            node = self.nodes[iRand]
            ccc -= 1
            
        }
    }
    
    private func removeLink() {
        
        if self.links.numberOfKeys > 0 {
            let linkKeys = self.links.inorderArrayFromKeys
            let randomIndex = randomInt(min: 0, max: linkKeys.count)
            
            self.links.remove(linkKeys[randomIndex])
        }
        
        
    }
    
    private func enableLink(database: NDatabase) {
        
        let linkKeys = self.links.inorderArrayFromKeys
        
        var iRand = randomInt(min: 0, max: linkKeys.count)
        var link = self.links.value(for: linkKeys[iRand])!
        var ccc = 10
        
        while ccc > 0 {
            if !link.enabled {
                link.enable()
                self.links.remove(link.innovation)
                self.links.insert(link, for: link.innovation)
                break
            }
            iRand = randomInt(min: 0, max: linkKeys.count)
            link = self.links.value(for: linkKeys[iRand])!
            ccc -= 1
        }
        
    }
    
    private func disableLink(database: NDatabase) {
        
        let linkKeys = self.links.inorderArrayFromKeys
        
        var iRand = randomInt(min: 0, max: linkKeys.count)
        var link = self.links.value(for: linkKeys[iRand])!
        var ccc = 10
        
        while ccc > 0 {
            if link.enabled {
                link.disable()
                self.links.remove(link.innovation)
                self.links.insert(link, for: link.innovation)
                break
            }
            iRand = randomInt(min: 0, max: linkKeys.count)
            link = self.links.value(for: linkKeys[iRand])!
            ccc -= 1
        }
        
    }
    
    private func addNode(database: NDatabase) {
        
        // Find a random link to be split
        let linkKeys = self.links.inorderArrayFromKeys
        
        
        var randomLinkKeyIndex = randomInt(min: 0, max: linkKeys.count)
        var linkToSplit = self.links.value(for: linkKeys[randomLinkKeyIndex])!
        
        var killer = 10
        while (linkToSplit.from == linkToSplit.to) || linkToSplit.from == database.biasId {
            if killer <= 0 { return }
            randomLinkKeyIndex = randomInt(min: 0, max: linkKeys.count)
            linkToSplit = self.links.value(for: linkKeys[randomLinkKeyIndex])!
            killer -= 1
        }
        
        linkToSplit.enabled = false
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
        if linkData.isEmpty { // No node exists so create an entirely new one
            newNode = NNode(id: database.nextNodeId(), type: NType.hidden, position: newNodePosition, activation: NRandomActivationType())
            // Also, no connections exist so create new connections below...
            
            var linkA = NLink(innovation: database.nextInnovation(), to: newNode.id, from: linkToSplit.from, weight: NRandom(), enabled: true, recurrent: false)
            linkA.weight = 1
            
            database.insertLink(link: linkA)
            var linkB = NLink(innovation: database.nextInnovation(), to: linkToSplit.to, from: newNode.id, weight: NRandom(), enabled: true, recurrent: false)
            linkB.weight = linkToSplit.weight
            database.insertLink(link: linkB)
            
            newNode.incommingLinks += [linkA]
            newNode.outgoingLinks += [linkB]
            
            self.links.insert(linkA, for: linkA.innovation)
            self.links.insert(linkB, for: linkB.innovation)
            
            
        } else { // links already exist with a node given in linkData
            newNode = NNode(id: linkData.first!, type: NType.hidden, position: newNodePosition, activation: NRandomActivationType())
            // Therefore, add the links that exist into this genome below...
            let linkAId = database.getInnovationId(from: linkToSplit.from, to: linkData.first!)
            let linkBId = database.getInnovationId(from: linkData.first!, to: linkToSplit.to)
            if (linkAId == -1) || (linkBId == -1) { fatalError() }
            var linkA = database.getLink(innovation: linkAId)
            linkA.weight = 1
            linkA.enabled = true
            var linkB = database.getLink(innovation: linkBId)
            linkB.weight = linkToSplit.weight
            
            newNode.incommingLinks += [linkA]
            newNode.outgoingLinks += [linkB]
            
            self.links.insert(linkA, for: linkAId)
            self.links.insert(linkB, for: linkBId)
        }
        
        if !self.nodes.contains(newNode) {
            self.nodes += [newNode]
        } else {
            for nodeId in 0..<self.nodes.count {
                if self.nodes[nodeId].id == newNode.id {
                    self.nodes[nodeId] = newNode
                    break
                }
            }
        }
        
        
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
            } else if node.type == NType.input || node.type == NType.bias {
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
            for _ in 1...Int(database.timesToFindConnection) {
                
                let randInId = randomInt(min: 0, max: inputHiddenIds.count)
                let randOutId = randomInt(min: 0, max: hiddenOutputIds.count)
                if inputNodeIds.contains(randOutId) { continue }
                if outputNodeIds.contains(randInId) && (randOutId == randInId) { continue }
                let toId = hiddenOutputIds[randOutId]
                let fromId = inputHiddenIds[randInId]
                
                var fromNode: NNode?
                var toNode: NNode?
                
                for node in self.nodes {
                    if node.id == toId { toNode = node; break }
                }
                for node in self.nodes {
                    if node.id == fromId { fromNode = node; break }
                }
                
                if fromNode!.position.y >= toNode!.position.y { continue }
                
                let potentialInnovationId = database.getInnovationId(from: fromId, to: toId)
                
                if potentialInnovationId != -1 { // Innovation already exists
                    // Check if this already exists in this genome
                    if self.links.value(for: potentialInnovationId) != nil { // Link does exist, so continue.
                        var link = self.links.value(for: potentialInnovationId)!
                        if toId == fromId {
                            link.recurrent = true
                        }
                        self.links.remove(link.innovation)
                        self.links.insert(link, for: link.innovation)
                        continue
                    }
                    
                    var recurrency = false
                    
                    if toId == fromId {
                        recurrency = true
                    }
                    
                    // Link does not exist in this genome but does exist globally
                    //var newLink = NLink(innovation: potentialInnovationId, to: toId, from: fromId)
                    let newLink = NLink(innovation: potentialInnovationId, to: toId, from: fromId, weight: NRandom(), enabled: true, recurrent: recurrency)
                    
                    
                    for node in 0..<self.nodes.count {
                        if self.nodes[node].id == toId {
                            self.nodes[node].incommingLinks += [newLink]
                        }
                    }
                    
                    for node in 0..<self.nodes.count {
                        if self.nodes[node].id == fromId {
                            self.nodes[node].outgoingLinks += [newLink]
                        }
                    }
                    
                    self.links.insert(newLink, for: potentialInnovationId)
                    break
                    
                } else { // innovation does not exist (assuming that it doesn't exist globally and in this genome)
                    
                    // Check if this already exists in this genome
                    if self.links.value(for: potentialInnovationId) != nil { // Link does exist, so continue.
                        continue
                    }
                    
                    var recurrency = false
                    
                    if toId == fromId {
                        recurrency = true
                    }
                    
                    // Link does not exist in this genome but does exist globally
                    let newLink = NLink(innovation: database.nextInnovation(), to: toId, from: fromId, weight: NRandom(), enabled: true, recurrent: recurrency)
                    
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
                    break
                }
            }
            
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
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        let newLinks: BTree<Int, NLink> = BTree(order: BTREEORDER)!
        
        self.links.traverseKeysInOrder { key in
            let link = self.links.value(for: key)!
            let newLink = NLink(innovation: link.innovation, to: link.to, from: link.from, weight: link.weight, enabled: link.enabled, recurrent: link.recurrent)
            newLinks.insert(newLink, for: link.innovation)
        }
        
        return NGenome(id: id, nodes: nodes, links: newLinks, fitness: fitness)
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
            n += "NODE_\(node.id), Type: \(node.type), Activation: \(node.activation), Activation Response: \(node.activationResponse), Position: \(node.position)\n"
        }
        
        for node in self.nodes {
            let incomingLinks = node.incommingLinks
            for link in incomingLinks {
                self.links.remove(link.innovation)
                self.links.insert(link, for: link.innovation)
            }
        }
        
        self.links.traverseKeysInOrder { key in
            let theLink = self.links.value(for: key)!
            
            l += "Innovation_\(theLink.innovation), [ from=\(theLink.from) : to=\(theLink.to) ], Enabled: \(theLink.enabled), Recurrent: \(theLink.recurrent), Weight: \(theLink.weight) --\n"
        }
        
        s += "\n    Genome_\(self.id),\n\n    fitness: \(self.fitness)\n"
        return s + n + l
    }
}
