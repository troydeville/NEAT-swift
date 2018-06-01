import Foundation


public class NSpecies {
    
    var id: Int
    
    var genomes: BTree<Int, NGenome> = BTree(order: BTREEORDER)!
    var genomePool = [NGenome]()
    var leader: NGenome
    
    public var King: NGenome = NGenome()
    
    var bestFitness = 0.0
    var variance = 0.0
    var averageFitness = 0.0
    var averageAdjustedFitness = 0.0
    var noImprovement = 0
    var age = 0
    var amountToSpawn = 0.0
    
    var database: NDatabase
    
    var keysRemoved = [Int]()
    
    var referenceToReturnAfterRestoringTheDead = [NGenome]()
    
    init(id: Int, leader: NGenome, database: NDatabase) {
        self.id = id
        self.leader = leader
        genomes.insert(leader, for: leader.id)
        self.database = database
    }
    
    func insertGenome(genome: NGenome) {
        self.genomes.insert(genome, for: genome.id)
    }
    
    func getLeader() -> NGenome {
        return self.leader
    }
    
    func removePopulation() {
        //reset from previous generation
        /*
         let genomeKeys = self.genomes.inorderArrayFromKeys
         for key in genomeKeys {
         self.genomes.remove(key)
         }
         */
        self.genomes = BTree(order: BTREEORDER)!
        
        self.genomePool = [NGenome]()
        self.keysRemoved.removeAll()
        
        // clear from previous generations
        self.referenceToReturnAfterRestoringTheDead.removeAll()
        
    }
    
    func adjustFitnesses() -> Double {
        
        //let genomeKeys = self.genomes.inorderArrayFromKeys
        let genomeAmount = Double(self.genomes.numberOfKeys)
        
        var tot = 0.0
        var totFit = 0.0
        
        self.genomes.traverseKeysInOrder { key in
            let genome = genomes.value(for: key)!
            
            totFit += genome.fitness
            /*
             
             var fitnessToAdjust = genome.fitness
             
             if self.age < 20 {
             fitnessToAdjust *= 1.5
             } else if self.age > 50 && noImprovement > 10 {
             fitnessToAdjust *= 0.1
             } else if noImprovement > 10 && self.age >= 20 && self.age <= 50 {
             fitnessToAdjust *= 0.5
             }
             
             */
            
            genome.adjustedFitness = (genome.fitness / genomeAmount)// * fitnessToAdjust
            //genome.adjustedFitness = (genome.fitness / Double(self.database.population))
            
            tot += genome.adjustedFitness
            genomePool += [genome]
            
            if genome.fitness > self.bestFitness {
                self.bestFitness = genome.fitness
                self.King = genome.copy()
            }
        }
        
        let newAverageFitness = totFit/genomeAmount
        let newAverageAdjustedFitness = tot/genomeAmount
        //let newAverageFitness = totFit/Double(self.database.population)
        
        if newAverageFitness <= self.averageFitness {
            noImprovement += 1
        } else {
            noImprovement = 0
        }
        
        self.averageFitness = newAverageFitness
        self.averageAdjustedFitness = newAverageAdjustedFitness
        
        return averageFitness
    }
    
    func setSpawnAmounts(globalAdjustedFitness: Double) {
        //let genomeKeys = self.genomes.inorderArrayFromKeys
        var tot = 0.0
        var varianceSum = 0.0
        
        //print("The global adjusted fitness: \(globalAdjustedFitness)")
        
        self.genomes.traverseKeysInOrder { key in
            let genome = genomes.value(for: key)!
            
            tot += (genome.adjustedFitness / globalAdjustedFitness)
            
            varianceSum += (genome.fitness-self.averageFitness)*(genome.fitness-self.averageFitness)
        }
        
        
        //print("Total: \(tot)")
        
        /*
         for key in genomeKeys {
         let genome = genomes.value(for: key)!
         tot += genome.adjustedFitness / averageAdjustedFitness
         varianceSum += (genome.fitness-self.averageFitness)*(genome.fitness-self.averageFitness)
         }
         */
        self.amountToSpawn = round(tot)
        if self.amountToSpawn.isNaN { self.amountToSpawn = 0 }
        
        //print("Amount to spawn: \(amountToSpawn)")
        
        self.variance = varianceSum / Double(self.genomes.numberOfKeys)
    }
    
    func removeLowestPerformingMembers() {
        
        // remove all genomes whose fitness is less than the average fitness minus the variance
        //let fitnessThreshold = self.averageFitness - variance
        var genomeKeys = [Int]()
        
        var genomesToUse = [NGenome]()
        
        self.genomes.traverseKeysInOrder { key in
            genomesToUse += [self.genomes.value(for: key)!]
        }
        
        genomesToUse.sort { g1, g2 in
            g1.fitness < g2.fitness
        }
        
        for genome in genomesToUse {
            genomeKeys += [genome.id]
        }
        
        var counter = Double(genomeKeys.count) * 0.80
        
        if genomeKeys.count >= 9 {
            /*
             for _ in 1...tempGenomePool.count {
             let genomeToRemove = tempGenomePool.last!
             self.keysRemoved += [ genomeToRemove.id ]
             self.genomes.remove(genomeToRemove.id)
             print("THIS KEY?")
             counter -= 1
             if counter < 0.5 {
             break
             }
             }
             */
            //genomeKeys.reverse()
            
            for key in genomeKeys {
                let genome = genomes.value(for: key)!
                if genome.fitness < self.bestFitness {
                    self.keysRemoved += [key]
                    self.genomes.remove(key)
                    counter -= 1
                    if counter <= 2.0 {
                        break
                    }
                }
                
            }
            
            /*
             for key in genomeKeys {
             let genome = genomes.value(for: key)!
             if genome.fitness < fitnessThreshold && genome.fitness < self.bestFitness {
             self.keysRemoved += [key]
             self.genomes.remove(key)
             counter -= 1
             if counter < 0.5 {
             break
             }
             }
             }
             */
        }
        
        //print("Average fitness: \(self.averageFitness)\nFitness Variance: \(self.variance)")
    }
    
    func replaceMissingGenomes(database: NDatabase) {
        
        let removedGenomeAmount = self.keysRemoved.count
        
        //print("\nSpecies Actual Amount removed: \(removedGenomeAmount)\n")
        
        var remainingMemberKeys = self.genomes.inorderArrayFromKeys
        
        /* Every child created has the chance to be mutated. */
        if removedGenomeAmount > 0 && remainingMemberKeys.count > 1 {
            
            for _ in 1...removedGenomeAmount {
                
                if normalRandom() <= 0.75 {
                    // Grab a random member from the remaining population
                    let randomKeyA = randomInt(min: 0, max: remainingMemberKeys.count)
                    var randomKeyB = randomInt(min: 0, max: remainingMemberKeys.count)
                    while randomKeyA == randomKeyB {
                        randomKeyB = randomInt(min: 0, max: remainingMemberKeys.count)
                    }
                    let genomeA = self.genomes.value(for: remainingMemberKeys[randomKeyA])!
                    let genomeB = self.genomes.value(for: remainingMemberKeys[randomKeyB])!
                    let child = crossOver(g1: genomeA, g2: genomeB, database: database)
                    child.mutate(database: database)
                    //print("Just mutated...1")
                    self.genomes.insert(child, for: child.id)
                    self.referenceToReturnAfterRestoringTheDead += [child]
                } else {
                    // Grab a random member from the remaining population
                    let randomKey = randomInt(min: 0, max: remainingMemberKeys.count)
                    
                    let genome = self.genomes.value(for: remainingMemberKeys[randomKey])!
                    
                    let genomeLinks = genome.getLinks()
                    let newLinks: BTree<Int, NLink> = BTree(order: BTREEORDER)!
                    
                    genomeLinks.traverseKeysInOrder { key in
                        let genomeLink = genomeLinks.value(for: key)!
                        let newChildLink = database.getLink(innovation: genomeLink.innovation)
                        //let newChildlink = NLink(innovation: genomeLink.innovation, to: genomeLink.to, from: genomeLink.from, weight: genomeLink.weight, enabled: genomeLink.enabled, recurrent: genomeLink.recurrent)
                        //let newChildlink = NLink(innovation: genomeLink.innovation, to: genomeLink.to, from: genomeLink.from)
                        newLinks.insert(newChildLink, for: newChildLink.innovation)
                    }
                    
                    let newChildGenome = NGenome(id: database.nextGenomeId(), nodes: genome.getNodes(), links: newLinks, fitness: 0.0)
                    newChildGenome.mutate(database: database)
                    //print("Just mutated...2")
                    self.genomes.insert(newChildGenome, for: newChildGenome.id)
                    self.referenceToReturnAfterRestoringTheDead += [newChildGenome]
                }
                
            }
            
        } else if removedGenomeAmount > 0 {
            //print("Amount to remove: \(removedGenomeAmount)")
            for _ in 1...removedGenomeAmount {
                let kingLinks = self.getLeader().getLinks()
                //let linkKeys = kingLinks.inorderArrayFromKeys
                let newLinks: BTree<Int, NLink> = BTree(order: BTREEORDER)!
                
                kingLinks.traverseKeysInOrder { key in
                    let kingLink = kingLinks.value(for: key)!
                    let newChildLink = database.getLink(innovation: kingLink.innovation)
                    //let newChildlink = NLink(innovation: kingLink.innovation, to: kingLink.to, from: kingLink.from, weight: kingLink.weight, enabled: kingLink.enabled, recurrent: kingLink.recurrent)
                    //let newChildlink = NLink(innovation: kingLink.innovation, to: kingLink.to, from: kingLink.from)
                    newLinks.insert(newChildLink, for: newChildLink.innovation)
                }
                let newChildGenome = NGenome(id: database.nextGenomeId(), nodes: self.getLeader().getNodes(), links: newLinks, fitness: 0.0)
                newChildGenome.mutate(database: database)
                //print("Just mutated...3")
                self.genomes.insert(newChildGenome, for: newChildGenome.id)
                self.referenceToReturnAfterRestoringTheDead += [newChildGenome]
            }
            
        }
        /*
         let otherGenomesToMutateCount = round(Double(remainingMemberKeys.count) * 0.25)
         
         if otherGenomesToMutateCount > 0 {
         for _ in 1...Int(otherGenomesToMutateCount) {
         let randIndex = randomInt(min: 0, max: remainingMemberKeys.count)
         let genome = self.genomes.value(for: remainingMemberKeys[randIndex])!
         if genome.fitness < self.bestFitness {
         genome.mutate(database: database)
         }
         remainingMemberKeys.remove(at: randIndex)
         }
         }
         */
    }
    
    func getReferenceOfTheNewChildren() -> [NGenome] {
        return self.referenceToReturnAfterRestoringTheDead
    }
    
    private func crossOver(g1: NGenome, g2: NGenome, database: NDatabase) -> NGenome {
        
        /**
         At this point, it is unclear if I should make the child weights the same as the parents it got it from.
         In this current implementation, a new link is created and has the default of creating a random weight.
         Therefore, the child will have the same link but with different weights.
         
         */
        
        var childNodes = [NNode]()
        
        //print("\n\n\n\n\n\nTHIS IS THE CHILD NODES: ")
        //print(g1.nodes)
        //print(g2.nodes)
        let childLinks: BTree<Int, NLink> = BTree(order: BTREEORDER)!
        
        let g1Innovations = g1.getInnovations(database: database)
        let g2Innovations = g2.getInnovations(database: database)
        
        let min: Int
        let max: Int
        
        let g1IMin = g1Innovations.first!
        let g1IMax = g1Innovations.last!
        
        let g2IMin = g2Innovations.first!
        let g2IMax = g2Innovations.last!
        
        if g1IMin < g2IMin { min = g1IMin } else { min = g2IMin }
        if g1IMax > g2IMax { max = g1IMax } else { max = g2IMax }
        
        var g1Inovs = [Int]()
        var g2Inovs = [Int]()
        var g1g2ORd = [Int]()
        var g1g2AND = [Int]()
        var adiffeb = [Int]()
        var g1Prime = [Int]()
        var g2Prime = [Int]()
        
        var matchingGenes = [Int]()
        var genomeAUnmatchingGenes = [Int]()
        var genomeBUnmatchingGenes = [Int]()
        var allUnmatchingGenesCount = 0
        
        for i in min...max {
            if g1Innovations.contains(i) { g1Inovs += [i] } else { g1Inovs += [0] }
            if g2Innovations.contains(i) { g2Inovs += [i] } else { g2Inovs += [0] }
            g1g2ORd += [g1Inovs.last! | g2Inovs.last!]
            g1g2AND += [g1Inovs.last! & g2Inovs.last!]
            if g1g2AND.last! != 0 {
                matchingGenes += [g1g2AND.last!]
            }
            adiffeb += [g1g2ORd.last! - g1g2AND.last!]
            g1Prime += [g1Inovs.last! & adiffeb.last!]
            g2Prime += [g2Inovs.last! & adiffeb.last!]
            if (g1Prime.last! - g2Prime.last! > 0) {
                genomeAUnmatchingGenes += [g1Prime.last!]
                allUnmatchingGenesCount += 1
            }
            
            if (g1Prime.last! - g2Prime.last! < 0) {
                genomeBUnmatchingGenes += [g2Prime.last!]
                allUnmatchingGenesCount += 1
            }
        }
        
        /* Start of creating the child links. */
        for innovationId in matchingGenes {
            
            //let g1Link = database.linkInnovations.value(for: innovationId)!
            var g1ChildLink = database.getLink(innovation: innovationId)
            
            //var g1ChildLink = NLink(innovation: innovationId, to: g1Link.nOut, from: g1Link.nIn, weight: g1Link.weight, enabled: g1Link.enabled, recurrent: g1Link.recurrent)
            let g2Link = database.linkInnovations.value(for: innovationId)!
            
            var g2ChildLink = database.getLink(innovation: g2Link.innovationID)
            //var g2ChildLink = NLink(innovation: g2Link.innovationID, to: g2Link.nOut, from: g2Link.nIn, weight: g2Link.weight, enabled: g2Link.enabled, recurrent: g2Link.recurrent)
            var eitherGenomeGeneWasDisabled = false
            if !g1ChildLink.enabled || !g2ChildLink.enabled { eitherGenomeGeneWasDisabled = true }
            // If parent 1 or parent 2 gene is disabled, then disable child gene
            if normalRandom() <= 0.5 {
                if eitherGenomeGeneWasDisabled { if normalRandom() <= 0.75 { g1ChildLink.disable() } }
                childLinks.insert(g1ChildLink, for: innovationId)
            } else {                // Use g2's link
                if eitherGenomeGeneWasDisabled { if normalRandom() <= 0.75 { g2ChildLink.disable() } }
                childLinks.insert(g2ChildLink, for: innovationId)
            }
        }
        
        if g1.fitness > g2.fitness {        // Use g1's unmatching genes
            for innovationId in genomeAUnmatchingGenes { // using g1's innovations here
                let g1Link = database.linkInnovations.value(for: innovationId)!
                
                var childLink = NLink(innovation: innovationId, to: g1Link.nOut, from: g1Link.nIn, weight: g1Link.weight, enabled: true, recurrent: g1Link.recurrent)
                //var childLink = NLink(innovation: innovationId, to: g1Link.nOut, from: g1Link.nIn)
                
                
                
                if !g1Link.enabled { if normalRandom() <= 0.75 { childLink.disable() } } // by chance, turns child gene off if was off in parent
                childLinks.insert(childLink, for: innovationId)
            }
        } else if g1.fitness < g2.fitness { // Use g2's unmatching genes
            for innovationId in genomeBUnmatchingGenes { // using g2's innovations here
                let g2Link = database.linkInnovations.value(for: innovationId)!
                
                var childLink = database.getLink(innovation: innovationId)
                childLink.enable()
                
                //var childLink = NLink(innovation: innovationId, to: g2Link.nOut, from: g2Link.nIn, weight: g2Link.weight, enabled: g2Link.enabled, recurrent: g2Link.recurrent)
                //var childLink = NLink(innovation: innovationId, to: g2Link.nOut, from: g2Link.nIn)
                if !g2Link.enabled { if normalRandom() <= 0.75 { childLink.disable() } } // by chance, turns child gene off if was off in parent
                childLinks.insert(childLink, for: innovationId)
            }
        } else if allUnmatchingGenesCount == 0 && g1.fitness != g2.fitness && genomeAUnmatchingGenes.isEmpty && genomeBUnmatchingGenes.isEmpty {
            for innovationId in genomeBUnmatchingGenes { // using g2's innovations here
                let g2Link = database.linkInnovations.value(for: innovationId)!
                var childLink = NLink(innovation: innovationId, to: g2Link.nOut, from: g2Link.nIn, weight: g2Link.weight, enabled: g2Link.enabled, recurrent: g2Link.recurrent)
                
                //var childLink = NLink(innovation: innovationId, to: g2Link.nOut, from: g2Link.nIn)
                if !g2Link.enabled { if normalRandom() <= 0.75 { childLink.disable() } } // by chance, turns child gene off if was off in parent
                childLinks.insert(childLink, for: innovationId)
                for node in g2.getNodes() {
                    childNodes += [node]
                }
            }
        } else if (g1.fitness == g2.fitness) && (allUnmatchingGenesCount > 0) && (!genomeAUnmatchingGenes.isEmpty && !genomeBUnmatchingGenes.isEmpty) {                            // Randomly choose the unmatching genes, need nodes too... barely happens
            let g1NodeCopy = g1.getNodes()
            let g2NodeCopy = g2.getNodes()
            
            for _ in 1...allUnmatchingGenesCount {
                
                if genomeAUnmatchingGenes.isEmpty || genomeBUnmatchingGenes.isEmpty { break }
                
                if normalRandom() <= 0.5 {       // Use g1's innovations
                    let innovationId = genomeAUnmatchingGenes.removeFirst()
                    let g1Link = database.linkInnovations.value(for: innovationId)!
                    var childLink = NLink(innovation: innovationId, to: g1Link.nOut, from: g1Link.nIn, weight: g1Link.weight, enabled: g1Link.enabled, recurrent: g1Link.recurrent)
                    //var childLink = NLink(innovation: innovationId, to: g1Link.nOut, from: g1Link.nIn)
                    if !g1Link.enabled { if normalRandom() <= 0.75 { childLink.disable() } } // by chance, turns child gene off if was off in parent
                    childLinks.insert(childLink, for: innovationId)
                    for node in g1NodeCopy {
                        if node.id == g1Link.nOut || node.id == g1Link.nIn {
                            childNodes += [node]
                        }
                    }
                } else {                    // Use g2's innovations
                    let innovationId = genomeBUnmatchingGenes.removeFirst()
                    let g2Link = database.linkInnovations.value(for: innovationId)!
                    var childLink = NLink(innovation: innovationId, to: g2Link.nOut, from: g2Link.nIn, weight: g2Link.weight, enabled: g2Link.enabled, recurrent: g2Link.recurrent)
                    
                    //var childLink = NLink(innovation: innovationId, to: g2Link.nOut, from: g2Link.nIn)
                    if !g2Link.enabled { if normalRandom() <= 0.75 { childLink.disable() } } // by chance, turns child gene off if was off in parent
                    childLinks.insert(childLink, for: innovationId)
                    for node in g2NodeCopy {
                        if node.id == g2Link.nOut || node.id == g2Link.nIn {
                            childNodes += [node]
                        }
                    }
                }
            }
            
            for identifier in matchingGenes { // add the matching gene nodes also
                let genomeLink = database.linkInnovations.value(for: identifier)!
                for node in g1NodeCopy {
                    if node.id == genomeLink.nOut || node.id == genomeLink.nIn {
                        childNodes += [node]
                    }
                }
            }
            
            // remove repeating node and sort ids in list
            childNodes = sortAndRemoveDuplicates(childNodes)
            
        }/* End of creating the child links */
        
        /* Nodes I'm assuming to be all from the most fit parent, unless they had equal fitness */
        
        if g1.fitness != g2.fitness { // Case that the nodes will be used by the most fit parent
            if g1.fitness > g2.fitness { // use g1's nodes
                //print(g1.getNodes())
                childNodes = g1.getNodes() // passing by value not reference (I think) it's a struct not a class
            } else { // Use g2's nodes
                childNodes = g2.getNodes()
            }
        } else if childNodes.isEmpty {
            childNodes = g2.getNodes()
        }
        
        //print(childNodes.count)
        
        return NGenome(id: database.nextGenomeId(), nodes: childNodes, links: childLinks, fitness: 0.0)
    }
    
    func incrimentAge() {
        self.age += 1
    }
    
    func isCompatable(g1: NGenome, g2: NGenome, threshConfig: [Double], database: NDatabase) -> Bool {
        
        let g1Innovations = g1.getInnovations(database: database)
        let g2Innovations = g2.getInnovations(database: database)
        
        let N: Double
        
        if g1Innovations.count > g2Innovations.count {
            N = Double(g1Innovations.count)
        } else {
            N = Double(g2Innovations.count)
        }
        
        let min: Int
        let max: Int
        
        let g1IMin = g1Innovations.first!
        let g1IMax = g1Innovations.last!
        
        let g2IMin = g2Innovations.first!
        let g2IMax = g2Innovations.last!
        
        if g1IMin < g2IMin { min = g1IMin } else { min = g2IMin }
        if g1IMax > g2IMax { max = g1IMax } else { max = g2IMax }
        
        var g1Inovs = [Int]()
        var g2Inovs = [Int]()
        var g1g2ORd = [Int]()
        var g1g2AND = [Int]()
        var adiffeb = [Int]()
        var g1Prime = [Int]()
        var g2Prime = [Int]()
        
        var Dis = 0.0
        var Exc = 0.0
        
        var totalWeight = 0.0
        var matchingGenes = 0.0
        
        for i in min...max {
            if g1Innovations.contains(i) { g1Inovs += [i] } else { g1Inovs += [0] }
            if g2Innovations.contains(i) { g2Inovs += [i] } else { g2Inovs += [0] }
            if g1Innovations.contains(i) && g2Innovations.contains(i) {// Both share a gene
                //count the number of shared genes
                matchingGenes += 1.0
                var g1Weight = 0.0
                var g2Weight = 0.0
                //get weight difference of the shared genes to add to total weight
                let g1wc = g1.getLinks().value(for: i)
                let g2wc = g2.getLinks().value(for: i)
                if g1wc != nil && g2wc != nil {
                    g1Weight = g1wc!.weight
                    g2Weight = g2wc!.weight
                    totalWeight += abs(g1Weight - g2Weight)
                }
            }
            g1g2ORd += [g1Inovs.last! | g2Inovs.last!]
            g1g2AND += [g1Inovs.last! & g2Inovs.last!]
            adiffeb += [g1g2ORd.last! - g1g2AND.last!]
            g1Prime += [g1Inovs.last! & adiffeb.last!]
            g2Prime += [g2Inovs.last! & adiffeb.last!]
            
            /*
             if adiffeb.last! != 0 {
             Dis += 1
             }
             */
            
            if (g1Prime.last! - g2Prime.last! > 0) || (g1Prime.last! - g2Prime.last! < 0) {
                Dis += 1
            }
            
            
        }
        
        if g1IMax > g2IMax {
            while g1Prime.last! != 0 {
                Exc += 1
                g1Prime.removeLast()
            }
        } else if (g1IMax < g2IMax) {
            while g2Prime.last! != 0 {
                Exc += 1
                g2Prime.removeLast()
            }
        }
        
        Dis -= Exc
        
        let threshHold = threshConfig[0]
        let c1 = threshConfig[1]
        let c2 = threshConfig[2]
        let c3 = threshConfig[3]
        let avgWeightDif = totalWeight / matchingGenes
        var compatability = 0.0
        if N < 20 {
            compatability = (c1*Exc) + (c2*Dis) + (c3*avgWeightDif)
        } else {
            compatability = (c1*Exc/N) + (c2*Dis/N) + (c3*avgWeightDif)
        }
        
        if compatability < threshHold {
            return true
        }
        
        return false
    }
    
}
