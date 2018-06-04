#if os(Linux)
import Foundation
import Dispatch
#else
import Foundation
#endif

public class NNeuralNetworkM {
    
    //var benchMarkTest: Double = 0.0001
    
    // all of the genomes in the network
    private let genomes: BTree<Int, NGenome> = BTree(order: BTREEORDER)!
    public let species: BTree<Int, NSpecies> = BTree(order: BTREEORDER)!
    
    // Network's King Genome and Fitness Score
    public var king = NGenome()
    public var Master = NGenome()
    public var topFitnessScore = 0.0
    
    private var currentGenomeKeys = [Int]()
    private var currentGenomeKeyId = 0
    private var currentGenomeId: Int = 0
    
    private let database: NDatabase
    public let populationSize: Int
    
    var speciesThresholdCount = 1.0
    
    var generation = 0
    
    // Compatability Threshold Config
    var threshConf = [Double]()
    
    //var king: NGenome
    var threadCount: Int = 0
    
    var highestFitness = 0.0
    
    var queues = [DispatchQueue]()
    
    var nObj = [NeatTaskObject]()
    
    
    
    var genomeGroupA = [NGenome]()
    var genomeGroupB = [NGenome]()
    var genomeGroupC = [NGenome]()
    var genomeGroupD = [NGenome]()
    var genomeGroupE = [NGenome]()
    var genomeGroupF = [NGenome]()
    var genomeGroupG = [NGenome]()
    var genomeGroupH = [NGenome]()
    
    fileprivate var threadAComplete = false
    fileprivate var threadBComplete = false
    fileprivate var threadCComplete = false
    fileprivate var threadDComplete = false
    fileprivate var threadEComplete = false
    fileprivate var threadFComplete = false
    fileprivate var threadGComplete = false
    fileprivate var threadHComplete = false
    
    var canLeaveSection = false
    
    public init(inputs: Int, outputs: Int, population: Int, confURL: String) {
        
        self.populationSize = population
        
        var configFile: [String : Double] = [String : Double]()
        let url = URL(fileURLWithPath: confURL)
        do {
            let data = try Data(contentsOf: url)
            configFile = try JSONDecoder().decode([String : Double].self, from: data)
        } catch {
            print(error)
            fatalError()
        }// END
        
        
        
        self.database = NDatabase(population: population, inputs: inputs, outputs: outputs, config: configFile)
        
        // Fetch data from config
        threshConf += [configFile["threshHold"]!]
        threshConf += [configFile["c1"]!]
        threshConf += [configFile["c2"]!]
        threshConf += [configFile["c3"]!]
        self.threadCount = Int(configFile["threads"]!)
        
        for i in 1...threadCount {
            queues += [DispatchQueue(label: "NEAT_NETWORK_\(i)/\(threadCount)")]
        }
        
        for _ in 1...threadCount {
            nObj += [NeatTaskObject()]
        }
        
        
        var c = 1
        // initiate genomes of amount of population
        for amount in 1...population {
            let genome = NGenome(id: amount, inputs: inputs, outputs: outputs, database: self.database)
            genomes.insert(genome, for: genome.id)
            
            switch c {
            case 1:
                genomeGroupA += [genome]
            case 2:
                genomeGroupB += [genome]
            case 3:
                genomeGroupC += [genome]
            case 4:
                genomeGroupD += [genome]
            case 5:
                genomeGroupE += [genome]
            case 6:
                genomeGroupF += [genome]
            case 7:
                genomeGroupG += [genome]
            case 8:
                genomeGroupH += [genome]
                
            default: break
            }
            
            if amount % threadCount == 0 { c += 1 }
        }
        //self.genomes.value(for: currentGenomeKeys[currentGenomeKeyId])!.id
        currentGenomeKeys = self.genomes.inorderArrayFromKeys
        self.currentGenomeId = self.genomes.value(for: currentGenomeKeys[currentGenomeKeyId])!.id
        self.king = findKing()
        
    }
    
    public func encodeConfigurationFile(_ confURL: String) -> [String : Double] {
        var conf: [String : Double] = [String : Double]()
        let url = URL(fileURLWithPath: confURL)
        do {
            let data = try Data(contentsOf: url)
            conf = try JSONDecoder().decode([String : Double].self, from: data)
        } catch { }// END
        return conf
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
    
    public func run(inputs: [[Double]], expected: [[Double]], inputCount: Int, outputCount: Int, testType: NTestType) {
        
        let group = DispatchGroup()
        
        func calculateNetwork(threadIndex: Int) {
            
            switch threadIndex {
            case 1:
                group.enter()
                threadAComplete = false
                
                for genomeIndex in 0..<self.genomeGroupA.count {
                    var total = 0.0
                    
                    if (genomeGroupA.count - 1) < genomeIndex { break }
                    for i in 0..<inputs.count {
                        var network = NNetwork(genome: self.genomeGroupA[genomeIndex])
                        let output = network.run(inputsIn: inputs[i], networkType: NetworkType.SnapShot)
                        for o in 0..<output.count {
                            total += abs(expected[i][o] - output[o])
                        }
                    }
                    
                    var currentGenomeFitness = 0.0
                    
                    
                    if testType == NTestType.distanceSquared {
                        currentGenomeFitness = pow(Double(expected.count * expected.first!.count) - total, 2)
                    } else if testType == NTestType.distance {
                        currentGenomeFitness = abs(Double(expected.count * expected.first!.count) - total)
                    } else if testType == NTestType.classification {
                        currentGenomeFitness = pow(1 / total, 2)
                    }
                    
                    //print("total: \(total)")
                    
                    self.genomeGroupA[genomeIndex].fitness = currentGenomeFitness
                    
                }
                
                group.leave()
                threadAComplete = true
            case 2:
                group.enter()
                threadBComplete = false
                for genomeIndex in 0..<self.genomeGroupB.count {
                    var total = 0.0
                    
                    if (genomeGroupB.count - 1) < genomeIndex { break }
                    for i in 0..<inputs.count {
                        var network = NNetwork(genome: self.genomeGroupB[genomeIndex])
                        let output = network.run(inputsIn: inputs[i], networkType: NetworkType.SnapShot)
                        for o in 0..<output.count {
                            total += abs(expected[i][o] - output[o])
                            //print("Expected: \(expected[i][o]), Actual: \(output[o])")
                        }
                    }
                    
                    var currentGenomeFitness = 0.0
                    
                    if testType == NTestType.distanceSquared {
                        currentGenomeFitness = pow(Double(expected.count * expected.first!.count) - total, 2)
                    } else if testType == NTestType.distance {
                        currentGenomeFitness = abs(Double(expected.count * expected.first!.count) - total)
                    } else if testType == NTestType.classification {
                        currentGenomeFitness = pow(1 / total, 2)
                    }
                    
                    self.genomeGroupB[genomeIndex].fitness = currentGenomeFitness
                    /*
                     if currentGenomeFitness > pow(Double(expected.count * expected.first!.count), 2)*0.97 {
                     print(self.genomeGroupA[genomeIndex].description)
                     }
                     */
                    
                }
                
                group.leave()
                threadBComplete = true
            case 3:
                group.enter()
                threadCComplete = false
                for genomeIndex in 0..<self.genomeGroupC.count {
                    var total = 0.0
                    
                    if (genomeGroupC.count - 1) < genomeIndex { break }
                    for i in 0..<inputs.count {
                        var network = NNetwork(genome: self.genomeGroupC[genomeIndex])
                        let output = network.run(inputsIn: inputs[i], networkType: NetworkType.SnapShot)
                        for o in 0..<output.count {
                            total += abs(expected[i][o] - output[o])
                        }
                    }
                    
                    var currentGenomeFitness = 0.0
                    
                    if testType == NTestType.distanceSquared {
                        currentGenomeFitness = pow(Double(expected.count * expected.first!.count) - total, 2)
                    } else if testType == NTestType.distance {
                        currentGenomeFitness = abs(Double(expected.count * expected.first!.count) - total)
                    } else if testType == NTestType.classification {
                        currentGenomeFitness = pow(1 / total, 2)
                    }
                    
                    self.genomeGroupC[genomeIndex].fitness = currentGenomeFitness
                    /*
                     if currentGenomeFitness > pow(Double(expected.count * expected.first!.count), 2)*0.97 {
                     print(self.genomeGroupA[genomeIndex].description)
                     }
                     */
                    
                }
                
                group.leave()
                threadCComplete = true
            case 4:
                group.enter()
                threadDComplete = false
                for genomeIndex in 0..<self.genomeGroupD.count {
                    var total = 0.0
                    
                    if (genomeGroupD.count - 1) < genomeIndex { break }
                    for i in 0..<inputs.count {
                        var network = NNetwork(genome: self.genomeGroupD[genomeIndex])
                        let output = network.run(inputsIn: inputs[i], networkType: NetworkType.SnapShot)
                        for o in 0..<output.count {
                            total += abs(expected[i][o] - output[o])
                        }
                    }
                    
                    var currentGenomeFitness = 0.0
                    
                    if testType == NTestType.distanceSquared {
                        currentGenomeFitness = pow(Double(expected.count * expected.first!.count) - total, 2)
                    } else if testType == NTestType.distance {
                        currentGenomeFitness = abs(Double(expected.count * expected.first!.count) - total)
                    } else if testType == NTestType.classification {
                        currentGenomeFitness = pow(1 / total, 2)
                    }
                    
                    self.genomeGroupD[genomeIndex].fitness = currentGenomeFitness
                    /*
                     if currentGenomeFitness > pow(Double(expected.count * expected.first!.count), 2)*0.97 {
                     print(self.genomeGroupA[genomeIndex].description)
                     }
                     */
                    
                }
                
                group.leave()
                threadDComplete = true
            case 5:
                group.enter()
                threadEComplete = false
                for genomeIndex in 0..<self.genomeGroupE.count {
                    var total = 0.0
                    
                    if (genomeGroupE.count - 1) < genomeIndex { break }
                    for i in 0..<inputs.count {
                        var network = NNetwork(genome: self.genomeGroupE[genomeIndex])
                        let output = network.run(inputsIn: inputs[i], networkType: NetworkType.SnapShot)
                        for o in 0..<output.count {
                            total += abs(expected[i][o] - output[o])
                        }
                    }
                    
                    var currentGenomeFitness = 0.0
                    
                    if testType == NTestType.distanceSquared {
                        currentGenomeFitness = pow(Double(expected.count * expected.first!.count) - total, 2)
                    } else if testType == NTestType.distance {
                        currentGenomeFitness = abs(Double(expected.count * expected.first!.count) - total)
                    } else if testType == NTestType.classification {
                        currentGenomeFitness = pow(1 / total, 2)
                    }
                    
                    self.genomeGroupE[genomeIndex].fitness = currentGenomeFitness
                    /*
                     if currentGenomeFitness > pow(Double(expected.count * expected.first!.count), 2)*0.97 {
                     print(self.genomeGroupA[genomeIndex].description)
                     }
                     */
                    
                }
                
                group.leave()
                threadEComplete = true
            case 6:
                group.enter()
                threadFComplete = false
                for genomeIndex in 0..<self.genomeGroupF.count {
                    var total = 0.0
                    
                    if (genomeGroupF.count - 1) < genomeIndex { break }
                    for i in 0..<inputs.count {
                        var network = NNetwork(genome: self.genomeGroupF[genomeIndex])
                        let output = network.run(inputsIn: inputs[i], networkType: NetworkType.SnapShot)
                        for o in 0..<output.count {
                            total += abs(expected[i][o] - output[o])
                        }
                    }
                    
                    var currentGenomeFitness = 0.0
                    
                    if testType == NTestType.distanceSquared {
                        currentGenomeFitness = pow(Double(expected.count * expected.first!.count) - total, 2)
                    } else if testType == NTestType.distance {
                        currentGenomeFitness = abs(Double(expected.count * expected.first!.count) - total)
                    } else if testType == NTestType.classification {
                        currentGenomeFitness = pow(1 / total, 2)
                    }
                    
                    self.genomeGroupF[genomeIndex].fitness = currentGenomeFitness
                    /*
                     if currentGenomeFitness > pow(Double(expected.count * expected.first!.count), 2)*0.97 {
                     print(self.genomeGroupA[genomeIndex].description)
                     }
                     */
                    
                }
                
                group.leave()
                threadFComplete = true
            case 7:
                group.enter()
                threadGComplete = false
                for genomeIndex in 0..<self.genomeGroupG.count {
                    var total = 0.0
                    
                    if (genomeGroupG.count - 1) < genomeIndex { break }
                    for i in 0..<inputs.count {
                        var network = NNetwork(genome: self.genomeGroupG[genomeIndex])
                        let output = network.run(inputsIn: inputs[i], networkType: NetworkType.SnapShot)
                        for o in 0..<output.count {
                            total += abs(expected[i][o] - output[o])
                        }
                    }
                    
                    var currentGenomeFitness = 0.0
                    
                    if testType == NTestType.distanceSquared {
                        currentGenomeFitness = pow(Double(expected.count * expected.first!.count) - total, 2)
                    } else if testType == NTestType.distance {
                        currentGenomeFitness = abs(Double(expected.count * expected.first!.count) - total)
                    } else if testType == NTestType.classification {
                        currentGenomeFitness = pow(1 / total, 2)
                    }
                    
                    self.genomeGroupG[genomeIndex].fitness = currentGenomeFitness
                    /*
                     if currentGenomeFitness > pow(Double(expected.count * expected.first!.count), 2)*0.97 {
                     print(self.genomeGroupA[genomeIndex].description)
                     }
                     */
                    
                }
                
                group.leave()
                threadGComplete = true
            case 8:
                group.enter()
                threadHComplete = false
                for genomeIndex in 0..<self.genomeGroupH.count {
                    var total = 0.0
                    
                    if (genomeGroupH.count - 1) < genomeIndex { break }
                    for i in 0..<inputs.count {
                        var network = NNetwork(genome: self.genomeGroupH[genomeIndex])
                        let output = network.run(inputsIn: inputs[i], networkType: NetworkType.SnapShot)
                        for o in 0..<output.count {
                            total += abs(expected[i][o] - output[o])
                        }
                    }
                    
                    var currentGenomeFitness = 0.0
                    
                    if testType == NTestType.distanceSquared {
                        currentGenomeFitness = pow(Double(expected.count * expected.first!.count) - total, 2)
                    } else if testType == NTestType.distance {
                        currentGenomeFitness = abs(Double(expected.count * expected.first!.count) - total)
                    } else if testType == NTestType.classification {
                        currentGenomeFitness = pow(1 / total, 2)
                    }
                    
                    self.genomeGroupH[genomeIndex].fitness = currentGenomeFitness
                    /*
                     if currentGenomeFitness > pow(Double(expected.count * expected.first!.count), 2)*0.97 {
                     print(self.genomeGroupA[genomeIndex].description)
                     }
                     */
                    
                }
                
                group.leave()
                threadHComplete = true
            default: break
            }
            
            
        }
        
        for i in 0..<queues.count {
            //nObj[i].task(networkId: i + 1)
            
            queues[i].async(group: group, qos: .userInitiated, flags: .enforceQoS) {
                calculateNetwork(threadIndex: i + 1)
                
            }
        }
        
        canLeaveSection = false
        
        group.notify(queue: .global()) {
            self.canLeaveSection = true
        }
        
        //var network = NNetwork(genome: self.genomes.value(for: currentGenomeId)!)
        //return network.run(inputsIn: inputs, networkType: NetworkType.SnapShot)
        
        //self.king = findKing()
        
        while !canLeaveSection { }
        
        self.assignToSpecies(inputs: inputs, expected: expected, inputCount: inputCount, outputCount: outputCount, testType: testType)
    }
    
    public func assignToSpecies(inputs: [[Double]], expected: [[Double]], inputCount: Int, outputCount: Int, testType: NTestType) {
        //let speciesKeys = self.species.inorderArrayFromKeys
        
        
        
        for _ in 1...self.genomes.numberOfKeys {
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
        
        // If the oldest species is older than 5
        var oldest = 0
        self.species.traverseKeysInOrder { key in
            let s = self.species.value(for: key)!
            let sAge = s.age
            if sAge > oldest {
                oldest = sAge
            }
        }
        
        let thresholdPerturbAmount = 0.01
        
        
        if self.species.numberOfKeys > 4 {
            self.database.threshHold += thresholdPerturbAmount * speciesThresholdCount
            speciesThresholdCount += 1.0
        } else if self.species.numberOfKeys < 4 && oldest > 5 {
            self.database.threshHold -= thresholdPerturbAmount * speciesThresholdCount
            speciesThresholdCount += 1.0
        } else {
            speciesThresholdCount = 1.0
        }
        
        if generation % 50 == 0 && generation > 5 {
            
            // Fine tune the best genomes per species
            print("Optimizing.")
            
            var genomesToFineTune = [NGenome]()
            var idOfSpecies: [Int] = []
            
            self.species.traverseKeysInOrder { key in
                var highestFitness = 0.0
                var winnerKey = -1
                let s = self.species.value(for: key)!
                s.genomes.traverseKeysInOrder { gKey in
                    let g = s.genomes.value(for: gKey)!
                    if g.fitness > highestFitness {
                        highestFitness = g.fitness
                        winnerKey = gKey
                    }
                }
                if s.genomes.numberOfKeys > 0 {
                    genomesToFineTune += [s.genomes.value(for: winnerKey)!]
                    idOfSpecies += [s.id]
                }
                
            }
            
            for genome in 0..<genomesToFineTune.count {
                
                var threshhh = 0.1
                
                for _ in 1...10 {
                    let ss = self.species.value(for: idOfSpecies[genome])!
                    var testGenome = ss.genomes.value(for: genomesToFineTune[genome].id)!
                    //var testGenome = genomes.value(for: genomesToFineTune[genome].id)!.copy()
                    let prevScore = testGenome.fitness
                    var currentScore = 0.0
                    var counter = 0
                    let triesToDoIt = 10
                    var improved = false
                    
                    
                    
                    while (prevScore >= currentScore) && counter < triesToDoIt {
                        
                        let linkIds = testGenome.getLinks().inorderArrayFromKeys
                        let iRand = randomInt(min: 0, max: linkIds.count)
                        
                        if normalRandom() <= 0.5 {
                            var link = testGenome.links.value(for: linkIds[iRand])!
                            link.weight += threshhh * normalRandom()
                            testGenome.links.remove(link.innovation)
                            testGenome.links.insert(link, for: link.innovation)
                        } else {
                            var link = testGenome.links.value(for: linkIds[iRand])!
                            link.weight -= threshhh * normalRandom()
                            testGenome.links.remove(link.innovation)
                            testGenome.links.insert(link, for: link.innovation)
                        }
                        
                        currentScore = testNetwork(genome: testGenome, inputs: inputs, expected: expected, inputCount: inputCount, outputCount: outputCount, testType: testType, info: false)
                        
                        
                        if currentScore <= prevScore {
                            testGenome = genomes.value(for: genomesToFineTune[genome].id)!.copy()
                        } else {
                            testGenome.fitness = currentScore
                            improved = true
                            
                        }
                        counter += 1
                    }
                    threshhh /= 1.00001
                    if improved { // Did improve at this point if counter is less than 100
                        print(currentScore)
                        self.species.value(for: idOfSpecies[genome])!.genomes.remove(testGenome.id)
                        self.species.value(for: idOfSpecies[genome])!.genomes.insert(testGenome, for: testGenome.id)
                        /*
                         self.genomes.remove(testGenome.id)
                         self.genomes.insert(testGenome, for: testGenome.id)
                         */
                    }
                    
                }
            }
        }
        
        print(self.description)
        
        epoch()
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
            self.Master = self.species.value(for: keyWithHighestFitness)!.King.copy()
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
            species.removePopulation()
            
            /*
             if self.species.value(for: key)!.noImprovement > 10 {
             self.species.remove(key)
             }
             */
            
        }
        
        genomeGroupA.removeAll()
        genomeGroupB.removeAll()
        genomeGroupC.removeAll()
        genomeGroupD.removeAll()
        genomeGroupE.removeAll()
        genomeGroupF.removeAll()
        genomeGroupG.removeAll()
        genomeGroupH.removeAll()
        
        var c = 1
        self.genomes.traverseKeysInOrder { key in
            
            let genome = self.genomes.value(for: key)!
            switch c {
            case 1:
                genomeGroupA += [genome]
            case 2:
                genomeGroupB += [genome]
            case 3:
                genomeGroupC += [genome]
            case 4:
                genomeGroupD += [genome]
            case 5:
                genomeGroupE += [genome]
            case 6:
                genomeGroupF += [genome]
            case 7:
                genomeGroupG += [genome]
            case 8:
                genomeGroupH += [genome]
            default: break
            }
            
            if c % threadCount == 0 {
                c = 0
            }
            c += 1
        }
        /*
         print(genomeGroupA.count)
         print(genomeGroupB.count)
         print(genomeGroupC.count)
         print(genomeGroupD.count)
         print(genomeGroupE.count)
         print(genomeGroupF.count)
         print(genomeGroupG.count)
         print(genomeGroupH.count)
         */
        
        self.generation += 1
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

extension NNeuralNetworkM: CustomStringConvertible {
    /**
     *  Returns details of the network
     */
    public var description: String {
        //let keyDescription = "Genomes: \(self.currentGenomeKeys)\nInnovations: \(self.database.description)"
        var speciesDescription = ""
        //let sKeys = self.species.inorderArrayFromKeys
        
        self.species.traverseKeysInOrder { key in
            let s = self.species.value(for: key)!
            speciesDescription += "species -- id: \(s.id), age: \(s.age), contains: \(s.genomes.numberOfKeys), spawn: \(s.amountToSpawn), best: \(s.bestFitness)\n"
            //speciesDescription += "\(s.getLeader().description)"
        }
        
        var genomeDescription = ""
        self.genomes.traverseKeysInOrder { key in
            let g = self.genomes.value(for: key)!
            genomeDescription += "ID: \(g.id), fitness: \(g.fitness), \nDescription:\n\(g.description)"
        }
        /*
         for key in sKeys {
         let s = self.species.value(for: key)!
         speciesDescription += "species -- id: \(s.id), age: \(s.age), spawn: \(s.amountToSpawn), best: \(s.bestFitness)\n"
         }
         */
        return "\n" + speciesDescription + "\n"// + genomeDescription + "\n"
    }
}
