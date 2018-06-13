import Foundation

//public let BTREEORDER = 5
//public var BIASID = 0

public class NNeuralNetworkS {
    
    //var benchMarkTest: Double = 0.0001
    
    // all of the genomes in the network
    private let genomes: BTree<Int, NGenome> = BTree(order: BTREEORDER)!
    public let species: BTree<Int, NSpecies> = BTree(order: BTREEORDER)!
    
    // Network's King Genome and Fitness Score
    public var king = NGenome()
    public var topFitnessScore = 0.0
    public var Master = NGenome()
    
    private var currentGenomeKeys = [Int]()
    private var currentGenomeKeyId = 0
    private var currentGenomeId: Int = 0
    var speciesThresholdCount = 1.0
    
    private var database: NDatabase
    public var populationSize: Int = 0
    
    // Compatability Threshold Config
    var threshConf = [Double]()
    
    //var king: NGenome
    
    public init(inputs: Int, outputs: Int, population: Int, confFile: NConfiguration) {
        
        self.populationSize = population
        
        self.database = NDatabase(population: population, inputs: inputs, outputs: outputs, confFile: confFile)
        
        
        // initiate genomes of amount of population
        for amount in 1...population {
            let genome = NGenome(id: amount, inputs: inputs, outputs: outputs, database: self.database)
            genomes.insert(genome, for: genome.id)
        }
        //self.genomes.value(for: currentGenomeKeys[currentGenomeKeyId])!.id
        currentGenomeKeys = self.genomes.inorderArrayFromKeys
        self.currentGenomeId = self.genomes.value(for: currentGenomeKeys[currentGenomeKeyId])!.id
        self.king = findKing()
        
        
        threshConf += [confFile.threshHold]
        threshConf += [confFile.c1]
        threshConf += [confFile.c2]
        threshConf += [confFile.c3]
        
    }
    
    public func run(inputs: [Double], inputCount: Int, outputCount: Int) -> [Double] {
        var network = NNetwork(genome: self.genomes.value(for: currentGenomeId)!)
        return network.run(inputsIn: inputs, networkType: NetworkType.SnapShot)
    }
    
    public func testNetwork(genome: NGenome, inputs: [[Double]], expected: [[Double]], inputCount: Int, outputCount: Int, testType: NTestType, info: Bool) -> Double {
        var total = 0.0
        
        if info {
            for i in 0..<inputs.count {
                print("input: \(inputs[i]):\n")
                var network = NNetwork(genome: genome)
                let output = network.run(inputsIn: inputs[i], networkType: NetworkType.SnapShot)
                for o in 0..<output.count {
                    print("output: \(output[o])\n\n")
                    total += abs(expected[i][o] - output[o])
                }
            }
        } else {
            for i in 0..<inputs.count {
                //print("input: \(inputs[i]):\n")
                var network = NNetwork(genome: genome)
                let output = network.run(inputsIn: inputs[i], networkType: NetworkType.SnapShot)
                for o in 0..<output.count {
                    //print("output: \(output[o])\n\n")
                    total += abs(expected[i][o] - output[o])
                }
            }
        }
        var fitness = 0.0
        
        if testType == NTestType.distanceSquared {
            fitness = pow(Double(expected.count * expected.first!.count) - total, 2)
        } else if testType == NTestType.distance {
            fitness = abs(Double(expected.count * expected.first!.count) - total)
        } else if testType == NTestType.classification {
            fitness = pow(1 / total, 2)
        }
        //print("fitness: \(fitness)")
        return fitness
    }
    
    public func assignFitness(fitness: Double) {
        self.genomes.value(for: self.currentGenomeId)!.fitness = fitness
    }
    
    public func assignToSpecies() {
        //let speciesKeys = self.species.inorderArrayFromKeys
        
        var foundSpecies = false
        
        self.species.traverseKeysInOrder { key in
            if !foundSpecies {
                let s = self.species.value(for: key)!
                let currentGenome = self.genomes.value(for: currentGenomeId)!
                let isCompatable = s.isCompatable(g1: currentGenome, g2: s.getLeader(), database: database)
                if isCompatable {
                    foundSpecies = true
                    //print(currentGenome.description)
                    s.insertGenome(genome: currentGenome)
                }
            }
        }
        
        if !foundSpecies {
            let speciesId = database.nextSpeciesId()
            let s = NSpecies(id: speciesId, leader: self.genomes.value(for: currentGenomeId)!, database: database)
            
            species.insert(s, for: s.id)
        }
        nextGenomeId()
    }
    
    public func epoch() {
        
        var tot = 0.0
        
        var keysToRemove: [Int] = []
        
        var keyWithHighestFitness = -1
        
        var highestFound = 0.0
        
        self.species.traverseKeysInOrder { key in
            
            let s = self.species.value(for: key)!
            
            if s.King.fitness > highestFound {
                keyWithHighestFitness = key
                highestFound = s.King.fitness
            }
            
            if s.genomes.numberOfKeys == 0 {
                keysToRemove += [key]
            }
        }
        
        if keyWithHighestFitness != -1 {
            self.Master = self.species.value(for: keyWithHighestFitness)!.King.copy() as! NGenome
        }
        
        
        for key in keysToRemove {
            self.species.remove(key)
        }
        
        self.species.traverseKeysInOrder { key in
            tot += self.species.value(for: key)!.adjustFitnesses()
        }
        
        
        tot /= Double(self.populationSize)
        
        self.species.traverseKeysInOrder { key in
            
            let species = self.species.value(for: key)!
            
            species.setSpawnAmounts(globalAdjustedFitness: tot)
            species.incrimentAge()
            
            // get each species to eliminate it's lowest performing members
            species.removeLowestPerformingMembers()
            
            // remove the lowest performing genomes in this network that was removed in the species class
            let genomeToRemoveKeys = species.keysRemoved
            //print("Amount to remove: \(genomeToRemoveKeys.count)")
            for gKey in genomeToRemoveKeys {
                self.genomes.remove(gKey)
            }
            //self.currentGenomeKeys = self.genomes.inorderArrayFromKeys
            
            // replace entire species population by the reamining offspring per species.
            self.species.value(for: key)!.replaceMissingGenomes(database: self.database)
            
            // update this network with the newly created ones from the replacement
            let theChildren = self.species.value(for: key)!.getReferenceOfTheNewChildren()
            //print("Amount to restore: \(theChildren.count)")
            for child in theChildren {
                self.genomes.insert(child, for: child.id)
            }
            
            // reset the keys
            self.currentGenomeKeys = self.genomes.inorderArrayFromKeys
            self.currentGenomeId = self.genomes.value(for: currentGenomeKeys[currentGenomeKeyId])!.id
            
            
            // set the king
            self.king = self.findKing()
            
            // wipe species genomes
            species.removePopulation()
            
            /*
             if self.species.value(for: key)!.noImprovement > 20 {
             self.species.remove(key)
             }
             */
            
        }
        
    }
    
    public func nextGenomeId() {
        //self.genomes.value(for: currentGenomeKeys[currentGenomeKeyId])!.id
        if currentGenomeKeyId == populationSize - 1 {
            //currentGenomeKeys = self.genomes.inorderArrayFromKeys
            currentGenomeKeyId = 0
            self.currentGenomeId = self.genomes.value(for: currentGenomeKeys[currentGenomeKeyId])!.id
        } else {
            currentGenomeKeyId += 1
            self.currentGenomeId = self.genomes.value(for: currentGenomeKeys[currentGenomeKeyId])!.id
        }
    }
    
    public func findKing() -> NGenome {
        var newKing: NGenome = NGenome()
        var hFit = 0.0
        for key in self.currentGenomeKeys {
            let compareGenome = self.genomes.value(for: key)!
            if compareGenome.fitness > hFit {
                newKing = compareGenome.copy() as! NGenome
                hFit = compareGenome.fitness
                newKing.fitness = hFit
            }
        }
        
        if newKing.id == 0 { return self.king } else { return newKing }
    }
    
}

// MARK: NeuralNetwork extension: Decription

extension NNeuralNetworkS: CustomStringConvertible {
    /**
     *  Returns details of the network
     */
    public var description: String {
        //let keyDescription = "Genomes: \(self.currentGenomeKeys)\nInnovations: \(self.database.description)"
        var speciesDescription = ""
        //let sKeys = self.species.inorderArrayFromKeys
        
        self.species.traverseKeysInOrder { key in
            let s = self.species.value(for: key)!
            speciesDescription += "species -- id: \(s.id), age: \(s.age), spawn: \(s.amountToSpawn), best: \(s.bestFitness)\n"
        }
        /*
         for key in sKeys {
         let s = self.species.value(for: key)!
         speciesDescription += "species -- id: \(s.id), age: \(s.age), spawn: \(s.amountToSpawn), best: \(s.bestFitness)\n"
         }
         */
        return "\n" + speciesDescription + "\n"
    }
}
