import Foundation


func random() -> Double {
    return (Double(arc4random()) / Double(UINT32_MAX))
}

func randomWeight() -> Double {
    if random() < 0.5 {
        return random()
    } else {
        return random() * -1
    }
}

func randomInt(min: Int, max: Int) -> Int {
    if max < 0 {
        return 0
    }
    return min + Int(arc4random_uniform(UInt32((max + 1) - min)))
}

class Genome {
    
    private var id: Int = 0
    private lazy var neuronGenes: [NeuronGene] = [NeuronGene]()
    private lazy var linkGenes: [LinkGene] = [LinkGene]()
    private var fitness: Double = 0.0
    private var adjustedFitness: Double = 0.0
    private var amountToSpawn: Double = 0.0
    private var inputAmount: Int = 0
    private var outputAmount: Int = 0
    private var speciesID: Int = 0
    var phenotype: Phenotype = Phenotype()
    
    init() { }
    
    deinit {
        self.neuronGenes.removeAll()
        self.linkGenes.removeAll()
    }
    
    init(id: Int, inputs: Int, outputs: Int, database: Database) {
        
        self.inputAmount = inputs
        self.outputAmount = outputs
        
        var inovTemp = inputs + 1 + outputs
        
        self.id = id
        var nPos: Double = 0
        var xPosition: Double = 0
        /* Neurons */
        for id in 1...inputs {
            neuronGenes += [NeuronGene(id: id, type: NeuronType.input, x: xPosition, y: 0, rec: false, response: 1.0, activationType: ActivationType.relu)]
            xPosition += 100
        }
        neuronGenes += [NeuronGene(id: inputs + 1, type: NeuronType.bias, x: -200, y: 250, rec: false, response: 1.0, activationType: ActivationType.relu)]
        for id in (inputs + 2)...(outputs + inputs + 1) {
            neuronGenes += [NeuronGene(id: id, type: NeuronType.output, x: Double(inputs) * 25 + nPos, y: 200, rec: false, response: 1.0, activationType: ActivationType.sigmoid)]
            nPos += 100
        }
        
        /* Links */
        for i in 1...(inputs + 1) {
            for o in (inputs + 2)...(outputs + inputs + 1) {
                linkGenes += [LinkGene(i: i, o: o, w: randomWeight(), en: true, inov: inovTemp, rec: false)]
                inovTemp += 1
            }
        }
        
        
        
    }
    
    init(id: Int, neurons: [NeuronGene], links: [LinkGene], inputs: Int, outputs: Int) {
        self.inputAmount = inputs
        self.outputAmount = outputs
        
        self.linkGenes.removeAll()
        for link in links {
            self.linkGenes += [LinkGene(i: link.getFrom(), o: link.getTo(), w: link.getWeight(), en: link.isEnabled(), inov: link.getInnovation(), rec: link.isRecurrent())]
        }
        
        self.neuronGenes.removeAll()
        for n in neurons {
            self.neuronGenes += [NeuronGene(id: n.getId(), type: n.getType(), x: n.getXPos(), y: n.getYPos(), rec: n.isRecurrent(), response: n.getActivationResponse(), activationType: n.getActivationType())]
        }
        
        self.neuronGenes.sort { ng1, ng2 in
            ng1.getId() < ng2.getId()
        }
        
        self.linkGenes.sort { lg1, lg2 in
            lg1.getInnovation() < lg2.getInnovation()
        }
        
    }
    
    func getNeuronGenes() -> [NeuronGene] {
        return self.neuronGenes
    }
    
    func getLinkGenes() -> [LinkGene] {
        return self.linkGenes
    }
    
    func mutate(nodeMutCh: Double, conMutCha: Double, weightMutCha: Double, activMutCha: Double, wPertubeAmount: Double, aPertubeAmount: Double, enMutCha: Double, database: Database) {
        
        addNeuron(mutationRate: nodeMutCh, innovationDataBase: database, numTriesToFindOldLink: 100)
        
        addLink(mutationRate: conMutCha, chanceOfLooped: 0.1, innovationDataBase: database, numTriesFindLoop: 100, numTriesAddLink: 200)
        
        var wP: Double = wPertubeAmount
        var aP: Double = aPertubeAmount
        
        if random() < 0.5 {
            wP = -wPertubeAmount
        }
        if random() < 0.5 {
            aP = -aPertubeAmount
        }
        
        changeWeight(mutationRate: weightMutCha, amount: wP)
        
        changeActivationResponse(mutationRate: activMutCha, amount: aP)
        
        enableGenes(mutationRate: enMutCha)
        
        changeActivation(mutationRate: database.changeActivType)
        
    }
    
    func getAmountToSpawn() -> Double {
        return self.amountToSpawn
    }
    
    func setAmountToSpawn(amount: Double) {
        self.amountToSpawn = amount
    }
    
    func getFitness() -> Double {
        return self.fitness
    }
    
    func setFitness(fit: Double) {
        self.fitness = fit
    }
    
    func enableGenes(mutationRate: Double) {
        for g in 0..<self.linkGenes.count {
            if random() < mutationRate {
                if random() < 0.9 {
                    self.linkGenes[g].enableConnection(true)
                } else {
                    self.linkGenes[g].enableConnection(true)
                }
                
            }
        }
    }
    
    func duplicateLink(neuronID1: Int, neuronID2: Int) -> Bool {
        let linkIn = neuronID1
        let linkOut = neuronID2
        
        for link in self.linkGenes {
            if (link.getFrom() == linkIn) && (link.getTo() == linkOut) {
                return true
            }
        }
        return false
    }
    /*
     func getNeuronPosition(id: Int) -> Int {
     for (i, neuron) in self.neuronGenes.enumerated() {
     if neuron.getId() == id {
     return i
     }
     }
     return -1
     }
     */
    func getNeuronPosition(id: Int) -> Int {
        for i in 0..<self.neuronGenes.count {
            if neuronGenes[i].getId() == id {
                return i
            }
            
        }
        return -1
    }
    
    func changeWeight(mutationRate: Double, amount: Double) {
        for l in 0..<self.linkGenes.count {
            if random() < mutationRate {
                if random() < 0.5 {
                    self.linkGenes[l].pertubeWeight(amount: amount)
                } else {
                    self.linkGenes[l].pertubeWeight(amount: -amount)
                }
                
            }
        }
    }
    
    func changeActivationResponse(mutationRate: Double, amount: Double) {
        for n in 0..<self.neuronGenes.count {
            if random() < mutationRate {
                if random() < 0.5 {
                    self.neuronGenes[n].pertubeActivation(amount: amount)
                } else {
                    self.neuronGenes[n].pertubeActivation(amount: -amount)
                }
                
            }
        }
    }
    
    func changeActivation(mutationRate: Double) {
        
        if random() < mutationRate {
            let randIndex = randomInt(min: 0, max: neuronGenes.count - 1)
            
            self.neuronGenes[randIndex].changeActivation()
            
        }
    }
    
    func addLink(mutationRate: Double, chanceOfLooped: Double, innovationDataBase: Database, numTriesFindLoop: Int, numTriesAddLink: Int) {
        
        if random() > mutationRate {
            return
        }
        
        var neuron1_id: Int = -1
        var neuron2_id: Int = -1
        
        var recurrent: Bool = false
        
        if random() < chanceOfLooped {
            for _ in 1...numTriesFindLoop {
                
                let neuronPosition = randomInt(min: self.inputAmount + 1, max: neuronGenes.count - 1)
                if !neuronGenes[neuronPosition].isRecurrent() &&
                    (neuronGenes[neuronPosition].getType() != NeuronType.bias) &&
                    (neuronGenes[neuronPosition].getType() != NeuronType.input)
                {
                    neuron1_id = neuronGenes[neuronPosition].getId()
                    neuron2_id = neuronGenes[neuronPosition].getId()
                    recurrent = true
                    break
                }
            }
        } else {
            for _ in 1...numTriesAddLink {
                neuron1_id = neuronGenes[randomInt(min: 0, max: neuronGenes.count - 1)].getId()
                let n2 = neuronGenes[randomInt(min: inputAmount + 1, max: neuronGenes.count - 1)]
                neuron2_id = n2.getId()
                let neuron2_type: NeuronType = n2.getType()
                if (neuron2_type == NeuronType.input) || (neuron2_type == NeuronType.bias) {
                    continue
                }
                
                if !(duplicateLink(neuronID1: neuron1_id, neuronID2: neuron2_id)) || (neuron1_id == neuron2_id) {
                    break
                } else {
                    neuron1_id = -1
                    neuron2_id = -1
                }
            }
        }
        
        if (neuron1_id < 0) || (neuron2_id < 0) {
            return
        }
        
        let id: Int = innovationDataBase.checkInnovation(id_1: neuron1_id, id_2: neuron2_id, neuronID: -1)
        
        if neuronGenes[getNeuronPosition(id: neuron1_id)].getYPos() >=
            neuronGenes[getNeuronPosition(id: neuron2_id)].getYPos()
        {
            recurrent = true
        }
        
        if id < 0 {
            innovationDataBase.createNewLinkInnovation(neuron1_id: neuron1_id, neuron2_id: neuron2_id)
            
            let nID = innovationDataBase.currentInnovation() - 1
            
            if !linkExists(from: neuron1_id, to: neuron2_id) {
                self.linkGenes += [LinkGene(i: neuron1_id, o: neuron2_id, w: randomWeight(), en: true, inov: nID - 1, rec: recurrent)]
            }
            
        } else {
            if !linkExists(from: neuron1_id, to: neuron2_id) {
                self.linkGenes += [LinkGene(i: neuron1_id, o: neuron2_id, w: randomWeight(), en: true, inov: id, rec: recurrent)]
            }
        }
        
        return
    }
    
    func addNeuron(mutationRate: Double, innovationDataBase: Database, numTriesToFindOldLink: Int) {
        if random() > mutationRate {
            return
        }
        var done: Bool = false
        var chosenLink: Int = 0
        
        //let sizeThreshold: Int = inputAmount + outputAmount
        let sizeThreshold: Int = inputAmount + outputAmount + 5
        
        if self.linkGenes.count < sizeThreshold {
            
            for _ in 1...numTriesToFindOldLink {
                chosenLink = randomInt(min: 0, max: numGenes() - 1 - Int(sqrt(Double(numGenes()))))
                let fromNeuron: Int = self.linkGenes[chosenLink].getFrom()
                
                if (self.linkGenes[chosenLink].isEnabled()) &&
                    (!self.linkGenes[chosenLink].isRecurrent()) &&
                    (self.neuronGenes[getNeuronPosition(id: fromNeuron)].getType() != NeuronType.bias)
                {
                    done = true
                    break
                }
                
            }
            
            if !done {
                return
            }
            
        } else {
            var c = 100
            while !done {
                //print("stucka")
                chosenLink = randomInt(min: 0, max: numGenes() - 1)
                let fromNeuron: Int = self.linkGenes[chosenLink].getFrom()
                
                if (self.linkGenes[chosenLink].isEnabled()) &&
                    (!self.linkGenes[chosenLink].isRecurrent()) &&
                    (self.neuronGenes[getNeuronPosition(id: fromNeuron)].getType() != NeuronType.bias)
                {
                    done = true
                }
                c -= 1
                if c == 0 {
                    done = true
                }
            }
            
        }
        //print("Chosen Link: inov: \(self.linkGenes[chosenLink].getInnovation()), from: \(self.linkGenes[chosenLink].getFrom()), to: \(self.linkGenes[chosenLink].getTo())")
        self.linkGenes[chosenLink].isEnabled(false)
        let originalWeight: Double = self.linkGenes[chosenLink].getWeight()
        
        let from: Int = self.linkGenes[chosenLink].getFrom()
        let to: Int = self.linkGenes[chosenLink].getTo()
        let newDepth: Double = Double((self.neuronGenes[getNeuronPosition(id: from)].getPos().y +
            self.neuronGenes[getNeuronPosition(id: to)].getPos().y) / 2)
        let newWidth: Double = Double((self.neuronGenes[getNeuronPosition(id: from)].getPos().x +
            self.neuronGenes[getNeuronPosition(id: to)].getPos().x) / 2)
        //var id: Int = innovationDataBase.checkInnovation(id_1: from, id_2: to)
        var id: Int = innovationDataBase.checkNodeInLink(from: from, to: to)
        if id >= 0 {
            let neuronID: Int = innovationDataBase.checkNodeInLink(from: from, to: to)
            //innovationDataBase.createNewNodeInnovation(from: -1, to: -1, type: NeuronType.hidden, xPos: newWidth, yPos: newDepth)
            
            if alreadyHaveThisNeuronId(id: neuronID) {
                id = -1
            } else {
                self.neuronGenes += [NeuronGene(id: neuronID, type: NeuronType.hidden, x: newWidth, y: newDepth, rec: false, response: 1, activationType: randomActivationType())]
            }
            
        }
        
        if id < 0 {
            let newNeuronID: Int = innovationDataBase.createNewNodeInnovation(from: from, to: to, type: NeuronType.hidden, activationType: randomActivationType(), xPos: newWidth, yPos: newDepth)
            
            self.neuronGenes += [NeuronGene(id: newNeuronID, type: NeuronType.hidden, x: newWidth, y: newDepth, rec: false, response: 1, activationType: randomActivationType())]
            
            innovationDataBase.createNewLinkInnovation(neuron1_id: from, neuron2_id: newNeuronID)
            
            let idLink_1: Int = innovationDataBase.currentInnovation() - 1
            
            if !linkExists(from: from, to: newNeuronID) {
                self.linkGenes += [LinkGene(i: from, o: newNeuronID, w: 1.0, en: true, inov: idLink_1, rec: false)]
            }
            
            innovationDataBase.createNewLinkInnovation(neuron1_id: newNeuronID, neuron2_id: to)
            
            let idLink_2: Int = innovationDataBase.currentInnovation() - 1
            
            if !linkExists(from: newNeuronID, to: to) {
                self.linkGenes += [LinkGene(i: newNeuronID, o: to, w: originalWeight, en: true, inov: idLink_2, rec: false)]
            }
            
            
        } else {
            
            let newNeuronId: Int = innovationDataBase.getNeuronId(id: id)
            
            let link1_id = innovationDataBase.checkInnovation(id_1: from, id_2: newNeuronId, neuronID: -1)
            let link2_id = innovationDataBase.checkInnovation(id_1: newNeuronId, id_2: to, neuronID: -1)
            
            if link1_id < 0 || link2_id < 0 {
                print("PROBLEM!")
                return
            }
            
            
            if !linkExists(from: from, to: newNeuronId) && !linkExists(from: newNeuronId, to: to) {
                self.linkGenes += [LinkGene(i: from, o: newNeuronId, w: 1.0, en: true, inov: link1_id, rec: false),
                                   LinkGene(i: newNeuronId, o: to, w: originalWeight, en: true, inov: link2_id, rec: false)]
            }
            
            
        }
        return
        
    }
    
    func alreadyHaveThisNeuronId(id: Int) -> Bool {
        for neuron in self.neuronGenes {
            if neuron.getId() == id {
                return true
            }
        }
        return false
    }
    
    func setAdjustedFitness(adjusted: Double) {
        self.adjustedFitness = adjusted
    }
    
    func getAdjustedFitness() -> Double {
        return self.adjustedFitness
    }
    
    func numGenes() -> Int {
        return self.linkGenes.count
    }
    
    func getLinkGene(index: Int) -> LinkGene {
        return self.linkGenes[index]
    }
    
    func getEndOfGenes() -> Int {
        return self.linkGenes.count
    }
    
    func getInputCount() -> Int {
        return self.inputAmount
    }
    
    func getOutputCount() -> Int {
        return self.outputAmount
    }
    
    func getID() -> Int {
        return self.id
    }
    
    func linkExists(from: Int, to: Int) -> Bool {
        for link in self.linkGenes {
            if (link.getFrom() == from) && (link.getTo() == to) {
                return true
            }
        }
        return false
    }
    
    func createPhenotype(depth: Int) {
        
        deletePhenotype()
        
        
        
        var neurons: [Neuron] = [Neuron]()
        for neuron in 0..<self.neuronGenes.count {
            neurons += [Neuron(neuron: self.neuronGenes[neuron])]
        }
        
        for link in 0..<self.linkGenes.count {
            if self.linkGenes[link].isEnabled() {
                var element: Int = getNeuronPosition(id: self.linkGenes[link].getFrom())
                let fromNeuron: Neuron = neurons[element]
                
                element = getNeuronPosition(id: self.linkGenes[link].getTo())
                let toNeuron: Neuron = neurons[element]
                let tmplink: Link = Link(w: self.linkGenes[link].getWeight(), n_in: fromNeuron, n_out: toNeuron, rec: self.linkGenes[link].isRecurrent())
                fromNeuron.addOutgoingLink(link: tmplink)
                toNeuron.addIncommingLink(link: tmplink)
            }
        }
        
        self.phenotype = Phenotype(depth: depth, neurons: neurons)
    }
    
    func deletePhenotype() {
        self.phenotype.clear()
    }
    
    func sortLinkGenesByInnovation() {
        self.linkGenes.sort { lg1, lg2 in
            lg1.getInnovation() < lg2.getInnovation()
        }
    }
    
    func sort() {
        self.neuronGenes.sort { ng1, ng2 in
            ng1.getId() < ng2.getId()
        }
        sortLinkGenesByInnovation()
    }
    
    func toString() -> String {
        var s = "Genome:\nid: \(self.id), fitness: \(self.fitness), neurons: \(self.neuronGenes.count), links: \(numGenes())\n"
        s += "Links:\n"
        for link in self.linkGenes {
            s += "\(link.toString())\n"
        }
        s += "Neurons:\n"
        for neuron in self.neuronGenes {
            s += "\(neuron.toString())\n"
        }
        
        return s
    }
    
}









