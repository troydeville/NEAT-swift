import Foundation

public let BTREEORDER = 8
public var BIASID = 0

public class Neat {
    
    public let populationSize: Int
    
    private var networkS: NNeuralNetworkS?
    private var networkM: NNeuralNetworkM?
    private var multithread: Bool
    
    public init(inputs: Int, outputs: Int, population: Int, confFile: NConfiguration?, multithread: Bool) {
        self.populationSize = population
        
        if !multithread {
            if confFile == nil {
                networkS = NNeuralNetworkS(inputs: inputs, outputs: outputs, population: population, confFile: NConfiguration())
            } else {
                networkS = NNeuralNetworkS(inputs: inputs, outputs: outputs, population: population, confFile: confFile!)
            }
            
        } else {
            if confFile == nil {
                networkM = NNeuralNetworkM(inputs: inputs, outputs: outputs, population: population, confFile: NConfiguration())
            } else {
                networkM = NNeuralNetworkM(inputs: inputs, outputs: outputs, population: population, confFile: confFile!)
            }
            
        }
        
        self.multithread = multithread
    }
    
    public func defaultConfiguration() -> NConfiguration {
        return NConfiguration()
    }
    
    public func run(inputs: [Double], inputCount: Int, outputCount: Int) -> [Double] {
        if !multithread {
            return networkS!.run(inputs: inputs, inputCount: inputCount, outputCount: outputCount)
        }
        
        return [Double]()
    }
    
    public func run(inputs: [[Double]], expected: [[Double]], inputCount: Int, outputCount: Int, testType: NTestType) {
        if multithread {
            networkM!.run(inputs: inputs, expected: expected, inputCount: inputCount, outputCount: outputCount, testType: testType)
        }
    }
    
    public func run(inputs: [Double]) -> [Double] {
        
        
        return [0.0]
    }
    
    public func testNetwork(genome: NGenome, inputs: [[Double]], expected: [[Double]], inputCount: Int, outputCount: Int, testType: NTestType, info: Bool) -> Double {
        if multithread {
            return self.networkM!.testNetwork(genome: genome, inputs: inputs, expected: expected, inputCount: inputCount, outputCount: outputCount, testType: testType, info: info)
        }
        return 0.0
    }
    
    public func nextGenome(_ previouslyTestedGenomeFitness: Double) {
        // 1. Assign the fitness score to the genome.
        // 2. Add genome to a species.
        if !multithread {
            networkS!.assignFitness(fitness: previouslyTestedGenomeFitness)
            networkS!.assignToSpecies()
        }
    }
    
    public func epoch() {
        if !multithread {
            networkS!.epoch()
        } else {
            networkM!.epoch()
        }
    }
    
    public func getKing() -> NGenome {
        if !multithread {
            return networkS!.findKing()
        } else {
            return networkM!.Master
        }
    }
    
}

extension Neat: CustomStringConvertible {
    /**
     *  Returns details of the network
     */
    public var description: String {
        if !multithread {
            //let keyDescription = "Genomes: \(self.currentGenomeKeys)\nInnovations: \(self.database.description)"
            var speciesDescription = ""
            //let sKeys = self.species.inorderArrayFromKeys
            
            
            networkS!.species.traverseKeysInOrder { key in
                let s = networkS!.species.value(for: key)!
                speciesDescription += "species -- id: \(s.id), age: \(s.age), spawn: \(s.amountToSpawn), best: \(s.bestFitness)\n"
            }
            return "\n" + speciesDescription + "\n"
        } else {
            //let keyDescription = "Genomes: \(self.currentGenomeKeys)\nInnovations: \(self.database.description)"
            var speciesDescription = ""
            //let sKeys = self.species.inorderArrayFromKeys
            
            networkM!.species.traverseKeysInOrder { key in
                let s = networkM!.species.value(for: key)!
                speciesDescription += "species -- id: \(s.id), age: \(s.age), spawn: \(s.amountToSpawn), best: \(s.bestFitness)\n"
            }
            return "\n" + speciesDescription + "\n"
        }
        
        
    }
}
