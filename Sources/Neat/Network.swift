//
//  CGA.swift
//  Neural Network Creator
//
//  Created by Troy Deville on 7/17/17.
//  Copyright © 2017 Troy Deville. All rights reserved.
//

import Foundation

public enum Parent {
    case mom
    case dad
}

public enum RunType {
    case snapshot
    case active
}

public func randomActivationType() -> ActivationType {
    switch randomInt(min: 1, max: 7) {
    case 1:
        return ActivationType.add
    case 2:
        return ActivationType.sigmoid
    case 3:
        return ActivationType.tanh
    case 4:
        return ActivationType.relu
    case 5:
        return ActivationType.sine
    case 6:
        return ActivationType.abs
    case 7:
        return ActivationType.square
    default: return ActivationType.sigmoid
    }
}

public func Add(x: Double, response: Double) -> Double {
    return x + response
}

public func Sigmoid(x: Double, response: Double) -> Double {
    return 1 / (1 + exp((-1 * response) * x))
}

public func Tanh(x: Double, response: Double) -> Double {
    return tanh(x * response)
}

public func Relu(x: Double, response: Double) -> Double {
    if x <= 0.0 {
        return 0.0
    }
    return x * response
}

public func Sine(x: Double, response: Double) -> Double {
    return sin(x * response)
}

public func Abs(x: Double, response: Double) -> Double {
    return abs(x * response)
}

public func Square(x: Double, response: Double) -> Double {
    return x * x * response
}

public func SigmoidS(x: Double, response: Double) -> Double {
    return (sinh(x + response) / cosh(x + response))
    //return 1 / (1 + exp(-response * x))
    //return sin(response * x)
}

public class Network {
    
    private var database: Database
    private var species: [Species] = [Species]()
    private var population: [Genome] = [Genome]()
    private var generation: Int = 0
    //private var neurons: [Neuron] = [Neuron]()
    private var depth: Int = 0
    private var c1: Double = 1
    private var c2: Double = 1.2
    private var inputs: Int = 0
    private var outputs: Int = 0
    
    
    init(inputs: Int, outputs: Int, population: Int) {
        self.database = Database(inputs: inputs, outputs: outputs)
        self.database.setPopulation(pop: population)
        self.inputs = inputs
        self.outputs = outputs
        
        var xPosition: Double = 0
        var nPos: Double = 0
        /* Neurons */
        for _ in 1...inputs {
            //neuronGenes += [NeuronGene(id: id, type: NeuronType.input, x: 0, y: 0, rec: false, response: 1.0)]
            let _ = database.createNewNodeInnovation(from: -1, to: -1, type: NeuronType.input, activationType: ActivationType.sigmoid, xPos: xPosition, yPos: 0)
            xPosition += 100
        }
        //neuronGenes += [NeuronGene(id: inputs + 1, type: NeuronType.bias, x: 0, y: 0, rec: false, response: 1.0)]
        let _ = database.createNewNodeInnovation(from: -1, to: -1, type: NeuronType.bias, activationType: ActivationType.sigmoid, xPos: -200, yPos: 250)
        for _ in (inputs + 2)...(outputs + inputs + 1) {
            //neuronGenes += [NeuronGene(id: id, type: NeuronType.output, x: 10 / , y: 0, rec: false, response: 1.0)]
            let _ = database.createNewNodeInnovation(from: -1, to: -1, type: NeuronType.output, activationType: ActivationType.sigmoid, xPos: Double(inputs) * 25 + nPos, yPos: 200)
            nPos += 100
        }
        
        /* Links */
        for i in 1...(inputs + 1) {
            for o in (inputs + 2)...(outputs + inputs + 1) {
                //linkGenes += [LinkGene(i: i, o: o, w: randomWeight(), en: true, inov: inovTemp, rec: false)]
                database.createNewLinkInnovation(neuron1_id: i, neuron2_id: o)
            }
        }
        
        for _ in 1...population {
            self.population += [Genome(id: database.nextGenomeID(), inputs: inputs, outputs: outputs, database: database)]
        }
        
    }
    
    func getPopulation() -> [Genome] {
        return self.population
    }
    
    func getDatabase() -> Database {
        return self.database
    }
    
    func genomeCreatePhenotype(genomeIndex: Int, depth: Int) {
        self.population[genomeIndex].createPhenotype(depth: depth)
    }
    
    func genomeSetFitness(index: Int, fitness: Double) {
        population[index].setFitness(fit: fitness)
    }
    
    func compatabilityDistance(c1: Double, c2: Double, genomeA: Genome, genomeB: Genome) -> Double {
        
        var similar: Double = 0
        var notSimilar: Double = 0
        var weightDifference: Double = 0
        
        
        
        for i in 0..<genomeA.numGenes() {
            for j in 0..<genomeB.numGenes() {
                if genomeA.getLinkGene(index: i).getInnovation() == genomeB.getLinkGene(index: j).getInnovation() {
                    similar += 1
                    weightDifference += abs(genomeA.getLinkGene(index: i).getWeight() - genomeB.getLinkGene(index: j).getWeight())
                    break
                }
                
            }
        }
        
        weightDifference /= similar
        
        notSimilar += Double(genomeA.numGenes()) - similar
        notSimilar += Double(genomeB.numGenes()) - similar
        
        var N: Double
        
        if genomeA.numGenes() < 20 && genomeB.numGenes() < 20 {
            N = 1
        } else if genomeA.numGenes() > genomeB.numGenes() {
            N = Double(genomeA.numGenes())
        } else {
            N = Double(genomeB.numGenes())
        }
        //print(((c1 * notSimilar) / N) + (c2 * weightDifference))
        return ((c1 * notSimilar) / N) + (c2 * weightDifference)
        
    }
    
    func update(inputs: [Double], type: RunType, genome: Int) -> [Double] {
        var outputs: [Double] = [Double]()
        
        var flushCount: Int = 0
        
        if type == RunType.snapshot {
            flushCount = self.population[genome].phenotype.depth
        } else {
            flushCount = 1
        }
        
        for _ in 1...flushCount {
            
            outputs.removeAll()
            
            var cNeuron: Int = 0
            
            while self.population[genome].phenotype.neurons[cNeuron].type == NeuronType.input {
                self.population[genome].phenotype.neurons[cNeuron].setOutput(o: inputs[cNeuron])
                cNeuron += 1
            }
            
            // Set bias to 1
            self.population[genome].phenotype.neurons[cNeuron].output = 1.0
            cNeuron += 1
            while cNeuron < self.population[genome].phenotype.neurons.count {
                var sum: Double = 0
                for lnk in 0..<self.population[genome].phenotype.neurons[cNeuron].incommingLinks.count {
                    let weight: Double = self.population[genome].phenotype.neurons[cNeuron].incommingLinks[lnk].weight
                    let neuronOutput: Double = self.population[genome].phenotype.neurons[cNeuron].incommingLinks[lnk].neuron_in.output
                    sum += weight * neuronOutput
                }
                /*
                if self.population[genome].phenotype.neurons[cNeuron].type == NeuronType.hidden || self.population[genome].phenotype.neurons[cNeuron].type == NeuronType.input {
                    self.population[genome].phenotype.neurons[cNeuron].output = SigmoidS(x: sum, response: self.population[genome].phenotype.neurons[cNeuron].activationResponse)
                } else {
                    self.population[genome].phenotype.neurons[cNeuron].output = Sigmoid(x: sum, response: self.population[genome].phenotype.neurons[cNeuron].activationResponse)
                }
*/
                //let type = ActivationType.sigmoid
                let type = self.population[genome].phenotype.neurons[cNeuron].activationType
                switch type {
                case ActivationType.sigmoid:
                    self.population[genome].phenotype.neurons[cNeuron].output = Sigmoid(x: sum, response: self.population[genome].phenotype.neurons[cNeuron].activationResponse)
                case ActivationType.add:
                    self.population[genome].phenotype.neurons[cNeuron].output = Add(x: sum, response: self.population[genome].phenotype.neurons[cNeuron].activationResponse)
                case ActivationType.tanh:
                    self.population[genome].phenotype.neurons[cNeuron].output = Tanh(x: sum, response: self.population[genome].phenotype.neurons[cNeuron].activationResponse)
                case ActivationType.relu:
                    self.population[genome].phenotype.neurons[cNeuron].output = Relu(x: sum, response: self.population[genome].phenotype.neurons[cNeuron].activationResponse)
                case ActivationType.sine:
                    self.population[genome].phenotype.neurons[cNeuron].output = Sine(x: sum, response: self.population[genome].phenotype.neurons[cNeuron].activationResponse)
                case ActivationType.abs:
                    self.population[genome].phenotype.neurons[cNeuron].output = Abs(x: sum, response: self.population[genome].phenotype.neurons[cNeuron].activationResponse)
                case ActivationType.square:
                    self.population[genome].phenotype.neurons[cNeuron].output = Square(x: sum, response: self.population[genome].phenotype.neurons[cNeuron].activationResponse)
                }
                
                /*
                self.population[genome].phenotype.neurons[cNeuron].output = Sigmoid(x: sum, response: self.population[genome].phenotype.neurons[cNeuron].activationResponse)
                 */
                /*
                if self.population[genome].phenotype.neurons[cNeuron].type == NeuronType.output {
                    self.population[genome].phenotype.neurons[cNeuron].output = Sigmoid(x: sum, response: self.population[genome].phenotype.neurons[cNeuron].activationResponse)
                }
 
                if self.population[genome].phenotype.neurons[cNeuron].type == NeuronType.input {
                    self.population[genome].phenotype.neurons[cNeuron].output = Add(x: sum, response: self.population[genome].phenotype.neurons[cNeuron].activationResponse)
                }
                
                if self.population[genome].phenotype.neurons[cNeuron].type == NeuronType.bias {
                    self.population[genome].phenotype.neurons[cNeuron].output = Add(x: sum, response: self.population[genome].phenotype.neurons[cNeuron].activationResponse)
                }
 */
                if self.population[genome].phenotype.neurons[cNeuron].type == NeuronType.output {
                    outputs += [self.population[genome].phenotype.neurons[cNeuron].output]
                }
                
                cNeuron += 1
            }
            
        }
        
        if type == RunType.snapshot {
            for n in 0..<self.population[genome].phenotype.neurons.count {
                self.population[genome].phenotype.neurons[n].output = 0
            }
        }

        self.population[genome].phenotype.clear()
        
        
        
        return outputs
    }
    
    func genomeGetNeuronGenes(index: Int) -> [NeuronGene] {
        return self.population[index].getNeuronGenes()
    }
    
    func getGenome(index: Int) -> Genome {
        return self.population[index]
    }
    
    func assignToSpecies(genomeIndex: Int, thresh: Double) {
        if self.species.isEmpty {
            self.species += [Species(id: database.nextSpeciesID(), firstOrganism: self.population[genomeIndex])]
        } else {
            var wasAdded: Bool = false
            for s in 0..<self.species.count {
                if compatabilityDistance(c1: c1, c2: c2, genomeA: self.population[genomeIndex], genomeB: self.species[s].getLeader()) < thresh {
                    species[s].addMember(organism: self.population[genomeIndex])
                    wasAdded = true
                    break
                }
                
            }
            if !wasAdded {
                self.species += [Species(id: database.nextSpeciesID(), firstOrganism: self.population[genomeIndex])]
            }
        }
    }
    
    func getSpeciesCount() -> Int {
        return self.species.count
    }
    
    func epoch() {
        
        // Sort the population by fitness score
        self.population.sort { g1, g2 in
            g1.getFitness() > g2.getFitness()
        }
        
        // Assign individual to a species
        for g in 0..<self.population.count {
            assignToSpecies(genomeIndex: g, thresh: 3)
        }
        
        // Remove population
        self.population.removeAll()
        
        // Set an adjusted fitness score for each species population
        for s in 0..<self.species.count {
            self.species[s].adjustFitness()
        }
        
        // Get the average adjusted fitness score for the entire population before speciation
        var sum: Double = 0
        var count: Double = 0
        for speciess in species {
            for genome in speciess.getGenomePool() {
                sum += genome.getAdjustedFitness()
                count += 1
            }
            
        }
        let avg = sum / count
        //print("AVG: \(avg)")
        
        for s in 0..<species.count {
            self.species[s].setGenomeSpawnAmounts(avg: avg)
            self.species[s].setSpawnAmount()
            self.species[s].removeTheWeak(database: database)
            self.species[s].increaseAge()
            self.species[s].analize(stagnantAge: 15)
        }
        
        var speciesRemoved: Bool = false
        var continueSearching: Bool = true
        
        while continueSearching {
            for s in 0..<self.species.count {
                if species[s].getSpawnAmount() < 1 {
                    species.remove(at: s)
                    speciesRemoved = true
                    break
                }
            }
            
            if speciesRemoved {
                continueSearching = true
            } else {
                continueSearching = false
            }
            speciesRemoved = false
        }
 
        self.population.removeAll()
 
        
        for s in 0..<self.species.count {
            let genomes: [Genome] = self.species[s].getGenomePool()
            //print("Genome count: \(genomes.count)")
            if species[s].getSpawnAmount() > 0 {
                var cancel_1 = 0
                if species[s].getSpawnAmount() > 5 {
                    self.population += [species[s].getLeader()]
                    cancel_1 = 1
                }
                if self.species[s].getSpawnAmount() > 0 {
                    for _ in 1...self.species[s].getSpawnAmount() - cancel_1 {
                        let rand: Int = randomInt(min: 0, max: genomes.count - 1)
                        let g = genomes[rand]
                        g.setFitness(fit: genomes[rand].getFitness())
                        //g.mutate(nodeMutCh: database.nodeMutChance, conMutCha: database.connectionMutChance, weightMutCha: database.weightMutChance, activMutCha: database.activationMutChance, wPertubeAmount: database.weightPertubeAmount, aPertubeAmount: database.activationPertubeAmount, enMutCha: database.enableMutChance, database: database)
                        self.population += [Genome(id: g.getID(), neurons: g.getNeuronGenes(), links: g.getLinkGenes(), inputs: inputs, outputs: outputs)]
                    }
                }
                
                self.species[s].purge()
            }
            
        }
 
        while self.population.count < database.getPopulation() {
            self.population += [population[0]]
        }
        
        if self.species.count < 4 {
            c1 += 0.2
            c2 += 0.2
        }
        if self.species.count > 4 {
            c1 -= 0.2
            c2 -= 0.2
        }
        if c1 < 0 {
            c1 = 0
        }
        if c2 < 0 {
            c2 = 0
        }
        
        //print("\n**********************************")
    }
    
    func getSpeciesSpawnAmounts() -> Int {
        var amount: Int = 0
        
        for s in species {
            amount += s.getSpawnAmount()
        }
        
        return amount
    }
    
    func printSpecies() -> String {
        var sring: String = ""
        for s in species {
            sring += s.toString()
            sring += "\n"
        }
        return sring
    }
    
    func printPopulation() {
        for genome in self.population {
            print(genome.toString())
        }
    }
    
    func populationCount() -> Int {
        return self.population.count
    }
    
}










