import Foundation

public let BTREEORDER = 4

public class Neat {
    
    // all of the genomes in the network
    private let genomes: BTree<Int, NGenome> = BTree(order: BTREEORDER)!
    private let species: BTree<Int, NSpecies> = BTree(order: BTREEORDER)!
    
    // Network's King Genome and Fitness Score
    public var king = NGenome()
    public var topFitnessScore = 0.0
    
    private var currentGenomeKeys = [Int]()
    private var currentGenomeKeyId = 0
    private var currentGenomeId: Int
    
    private let database: NDatabase
    public let populationSize: Int
    
    // Compatability Threshold Config
    var threshConf = [Double]()
    
    //var king: NGenome
    
    init(inputs: Int, outputs: Int, population: Int, confURL: String) {
        
        self.database = NDatabase(population: population, inputs: inputs, outputs: outputs)
        
        self.populationSize = population
        
        // initiate genomes of amount of population
        for amount in 1...population {
            let genome = NGenome(id: amount, inputs: inputs, outputs: outputs, database: self.database)
            genomes.insert(genome, for: genome.id)
        }
        //self.genomes.value(for: currentGenomeKeys[currentGenomeKeyId])!.id
        currentGenomeKeys = self.genomes.inorderArrayFromKeys
        self.currentGenomeId = self.genomes.value(for: currentGenomeKeys[currentGenomeKeyId])!.id
        self.king = findKing()
        
        // Fetch data from config
        let configFile = self.encodeConfigurationFile(confURL)
        
        threshConf += [configFile["threshHold"]!]
        threshConf += [configFile["c1"]!]
        threshConf += [configFile["c2"]!]
        threshConf += [configFile["c3"]!]
        
    }
    
    func encodeConfigurationFile(_ confURL: String) -> [String : Double] {
        var conf: [String : Double] = [String : Double]()
        let url = URL(fileURLWithPath: confURL)
        do {
            let data = try Data(contentsOf: url)
            conf = try JSONDecoder().decode([String : Double].self, from: data)
        } catch { }// END
        return conf
    }
    
    func run(inputs: [Double], inputCount: Int, outputCount: Int) -> [Double] {
        //print(self.genomes.value(for: currentGenomeId)!.description)
        var network = NNetwork(genome: self.genomes.value(for: currentGenomeId)!)
        return network.run(inputsIn: inputs, networkType: NetworkType.SnapShot)
    }
    
    func assignFitness(fitness: Double) {
        self.genomes.value(for: self.currentGenomeId)!.fitness = fitness
    }
    
    func assignToSpecies() {
        let speciesKeys = self.species.inorderArrayFromKeys
        
        var foundSpecies = false
        
        for key in speciesKeys {// Find genome is compatible with the leader
            let s = self.species.value(for: key)!
            let currentGenome = self.genomes.value(for: currentGenomeId)!
            let isCompatable = s.isCompatable(g1: currentGenome, g2: s.getLeader(), threshConfig: threshConf, database: database)
            if isCompatable {
                foundSpecies = true
                //print(currentGenome.description)
                s.insertGenome(genome: currentGenome)
                break
            }
        }
        if !foundSpecies {
            let speciesId = database.nextSpeciesId()
            let s = NSpecies(id: speciesId, leader: self.genomes.value(for: currentGenomeId)!, database: database)
            
            //print("\n\n\n\n\nn\nHERE\n")
            //print(self.genomes.value(for: currentGenomeId)!)
            //print("\n")
            
            species.insert(s, for: s.id)
        }
        nextGenomeId()
    }
    
    func epoch() {
        let sKeys = self.species.inorderArrayFromKeys
        for key in sKeys {
            self.species.value(for: key)!.adjustFitnesses()
            self.species.value(for: key)!.setSpawnAmounts()
            self.species.value(for: key)!.incrimentAge()
            
            // get each species to eliminate it's lowest performing members
            self.species.value(for: key)!.removeLowestPerformingMembers()
            
            // remove the lowest performing genomes in this network that was removed in the species class
            let genomeToRemoveKeys = self.species.value(for: key)!.keysRemoved
            //print("Amount to remove: \(genomeToRemoveKeys.count)")
            for gKey in genomeToRemoveKeys {
                self.genomes.remove(gKey)
            }
            self.currentGenomeKeys = self.genomes.inorderArrayFromKeys
            
            
            // replace entire species population by the reamining offspring per species.
            self.species.value(for: key)!.replaceMissingGenomes(database: database)
            
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
            self.species.value(for: key)!.removePopulation()
            /*
            if self.species.value(for: key)!.noImprovement > 10 {
                self.species.remove(key)
            }
            */
        }
    }
    
    private func nextGenomeId() {
        //self.genomes.value(for: currentGenomeKeys[currentGenomeKeyId])!.id
        if currentGenomeKeyId == populationSize - 1 {
            currentGenomeKeys = self.genomes.inorderArrayFromKeys
            currentGenomeKeyId = 0
            self.currentGenomeId = self.genomes.value(for: currentGenomeKeys[currentGenomeKeyId])!.id
        } else {
            currentGenomeKeyId += 1
            self.currentGenomeId = self.genomes.value(for: currentGenomeKeys[currentGenomeKeyId])!.id
        }
    }
    
    func findKing() -> NGenome {
        var theKing: NGenome = NGenome()
        var hFit = 0.0
        for key in self.currentGenomeKeys {
            let compareGenome = self.genomes.value(for: key)!
            if compareGenome.fitness > hFit {
                theKing = compareGenome.copy()
                hFit = compareGenome.fitness
                theKing.fitness = hFit
            }
        }
        
        if theKing.id == 0 { return self.king } else { return theKing }
    }
    
}

// MARK: NeuralNetwork extension: Decription

extension Neat: CustomStringConvertible {
    /**
     *  Returns details of the network
     */
    public var description: String {
        //let keyDescription = "Genomes: \(self.currentGenomeKeys)\nInnovations: \(self.database.description)"
        var speciesDescription = ""
        let sKeys = self.species.inorderArrayFromKeys
        for key in sKeys {
            let s = self.species.value(for: key)!
            speciesDescription += "species -- id: \(s.id), age: \(s.age), spawn: \(s.amountToSpawn), best: \(s.bestFitness)\n"
        }
        
        return "\n" + speciesDescription + "\n"
    }
}
