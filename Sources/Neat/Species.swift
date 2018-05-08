//
//  Species.swift
//  Neural Network Creator
//
//  Created by Troy Deville on 7/17/17.
//  Copyright © 2017 Troy Deville. All rights reserved.
//

import Foundation

class Species {
    
    private var leader: Genome = Genome()
    private var organisms: [Genome] = [Genome]()
    private var id: Int = 0
    private var bestFitness: Double = 0.0
    private var averageFitness: Double = 0.0
    private var generationsNoImprovment: Int = 0
    private var age: Int = 0
    private var spawnsRequired: Double = 0.0
    private var averageAdjustedFitness: Double = 0
    private var stagnant: Bool = false
    private var ageNoProgress: Int = 0
    
    init() {}
    
    deinit {
        self.organisms.removeAll()
        
    }
    
    init(id: Int, firstOrganism: Genome) {
        self.id = id
        self.leader = firstOrganism
    }
    
    func addMember(organism: Genome) {
        self.organisms += [organism]
        organisms.sort { g1, g2 in
            g1.getFitness() > g2.getFitness()
        }
        if organism.getFitness() > self.bestFitness {
            self.bestFitness = organism.getFitness()
        }
    }
    
    func purge() {
        self.organisms = []
    }
    
    func getLeader() -> Genome {
        return self.leader
    }
    
    func setLeader(organism: Genome) {
        self.leader = organism
    }
    
    func clear() {
        
    }
    
    func removeTheWeak(database: Database) {
        //print("INSIDE SPECIES:")
        
        
        
        let removeAmount: Int = Int(Double(self.organisms.count) * 0.8)
        var children: [Genome] = [Genome]()
        if removeAmount > 0 {
            for _ in 1...removeAmount {
                self.organisms.remove(at: self.organisms.count - 1)
            }
            
            let c = Int(Double(Int(self.spawnsRequired) - self.organisms.count) * 0.75)
            
            if self.organisms.count > 1 {
                if !stagnant {
                    while children.count < c {
                        var momID: Int = 0
                        var dadID: Int = 0
                        while momID == dadID {
                            //print("stuckca")
                            momID = randomInt(min: 0, max: self.organisms.count - 1)
                            dadID = randomInt(min: 0, max: self.organisms.count - 1)
                        }
                        let mom = Genome(id: self.organisms[momID].getID(), neurons: self.organisms[momID].getNeuronGenes(), links: self.organisms[momID].getLinkGenes(), inputs: self.organisms[momID].getInputCount(), outputs: self.organisms[momID].getOutputCount())
                        mom.setFitness(fit: self.organisms[momID].getFitness())
                        let dad = Genome(id: self.organisms[dadID].getID(), neurons: self.organisms[dadID].getNeuronGenes(), links: self.organisms[dadID].getLinkGenes(), inputs: self.organisms[dadID].getInputCount(), outputs: self.organisms[dadID].getOutputCount())
                        dad.setFitness(fit: self.organisms[dadID].getFitness())
                        let child = crossOver(mom: mom, dad: dad, database: database)
                        child.mutate(nodeMutCh: database.nodeMutChance, conMutCha: database.connectionMutChance, weightMutCha: database.weightMutChance, activMutCha: database.activationMutChance, wPertubeAmount: database.weightPertubeAmount, aPertubeAmount: database.activationPertubeAmount, enMutCha: database.enableMutChance, database: database)
                        children += [child]
                    }
                } else {
                    while organisms.count < Int(self.spawnsRequired) {
                        let index = randomInt(min: 0, max: organisms.count - 1)
                        let newOrg = Genome(id: self.organisms[index].getID(), neurons: self.organisms[index].getNeuronGenes(), links: self.organisms[index].getLinkGenes(), inputs: self.organisms[index].getInputCount(), outputs: self.organisms[index].getOutputCount())
                        newOrg.setFitness(fit: self.organisms[index].getFitness())
                        newOrg.mutate(nodeMutCh: database.nodeMutChance, conMutCha: database.connectionMutChance, weightMutCha: database.weightMutChance, activMutCha: database.activationMutChance, wPertubeAmount: database.weightPertubeAmount, aPertubeAmount: database.activationPertubeAmount, enMutCha: database.enableMutChance, database: database)
                        self.organisms += [newOrg]
                    }
                }
                
            } else {
                while organisms.count < Int(self.spawnsRequired) {
                    let index = randomInt(min: 0, max: organisms.count - 1)
                    let newOrg = Genome(id: self.organisms[index].getID(), neurons: self.organisms[index].getNeuronGenes(), links: self.organisms[index].getLinkGenes(), inputs: self.organisms[index].getInputCount(), outputs: self.organisms[index].getOutputCount())
                    newOrg.setFitness(fit: self.organisms[index].getFitness())
                    newOrg.mutate(nodeMutCh: database.nodeMutChance, conMutCha: database.connectionMutChance, weightMutCha: database.weightMutChance, activMutCha: database.activationMutChance, wPertubeAmount: database.weightPertubeAmount, aPertubeAmount: database.activationPertubeAmount, enMutCha: database.enableMutChance, database: database)
                    self.organisms += [newOrg]
                }
            }
            if self.organisms.count > 0 {
                let o_ID: Int = randomInt(min: 0, max: organisms.count - 1)
                self.leader = Genome(id: organisms[o_ID].getID(), neurons: organisms[o_ID].getNeuronGenes(), links: organisms[o_ID].getLinkGenes(), inputs: organisms[o_ID].getInputCount(), outputs: organisms[o_ID].getOutputCount())
                self.leader.setFitness(fit: organisms[o_ID].getFitness())
            }
            self.organisms += children
            
            self.organisms.sort { g1, g2 in
                g1.getFitness() > g2.getFitness()
            }
            /*
            for o in organisms {
                print(o.toString())
            }
             */
            
            let randILeadIdx: Int = randomInt(min: 0, max: organisms.count - removeAmount)
            
            self.setLeader(organism: organisms[randILeadIdx])
        }
 
        
    }
    
    func getGenomePool() -> [Genome] {
        return self.organisms
    }
    
    func adjustFitness() {
        
        for gen in 0..<self.organisms.count {
            
            var o_fitness = self.organisms[gen].getFitness()
            
            if self.age < 5 {
                o_fitness *= 1.4
            }
            
            if self.stagnant {
                o_fitness *= 0.9
            }
            
            self.organisms[gen].setAdjustedFitness(adjusted: o_fitness / Double(self.organisms.count))
            
        }
        
    }
    
    
    func getAge() -> Int {
        return self.age
    }
    
    func getAverageAdjustedFitnessScore() -> Double {
        return self.averageAdjustedFitness
    }
    
    func setGenomeSpawnAmounts(avg: Double) {
        for gen in 0..<self.organisms.count {
            self.organisms[gen].setAmountToSpawn(amount: self.organisms[gen].getAdjustedFitness() / avg)
        }
    }
    
    func setSpawnAmount() {
        self.spawnsRequired = 0.0
        for gen in 0..<self.organisms.count {
            self.spawnsRequired += self.organisms[gen].getAmountToSpawn()
        }
        
        if self.spawnsRequired.isNaN {
            self.spawnsRequired = Double(self.organisms.count)
        }
 
    }
    
    func getSpawnAmount() -> Int {
        return Int(self.spawnsRequired)
    }
    
    func crossOver(mom: Genome, dad: Genome, database: Database) -> Genome {
        
        var bestParent: Parent
        
        if mom.getFitness() == dad.getFitness() {
            if mom.numGenes() == dad.numGenes() {
                if random() <= 0.5 {
                    bestParent = Parent.mom
                } else {
                    bestParent = Parent.dad
                }
            } else if mom.numGenes() < dad.numGenes() {
                bestParent = Parent.mom
            } else {
                bestParent = Parent.dad
            }
        } else if mom.getFitness() > dad.getFitness() {
            bestParent = Parent.mom
        } else {
            bestParent = Parent.dad
        }
        
        var babyNeuronGenes: [NeuronGene] = [NeuronGene]()
        var babyLinkGenes: [LinkGene] = [LinkGene]()
        
        var neuronIDs: [Int] = [Int]()
        
        var curMom: Int = 0
        var curDad: Int = 0
        
        var selectedGene: LinkGene = LinkGene()
        
        while !((curMom == mom.getEndOfGenes()) && curDad == dad.getEndOfGenes()) {
            //print("stuckc")
            if (curMom == mom.getEndOfGenes()) && (curDad != dad.getEndOfGenes()) {
                
                if bestParent == Parent.dad {
                    selectedGene = dad.getLinkGene(index: curDad)
                }
                
                curDad += 1
            } else if (curDad == dad.getEndOfGenes()) && (curMom != mom.getEndOfGenes()) {
                
                if bestParent == Parent.mom {
                    selectedGene = mom.getLinkGene(index: curMom)
                }
                
                curMom += 1
            } else if (mom.getLinkGene(index: curMom).getInnovation() < dad.getLinkGene(index: curDad).getInnovation()) {
                if bestParent == Parent.mom {
                    selectedGene = mom.getLinkGene(index: curMom)
                }
                curMom += 1
            } else if (dad.getLinkGene(index: curDad).getInnovation() < mom.getLinkGene(index: curMom).getInnovation()) {
                if bestParent == Parent.dad {
                    selectedGene = dad.getLinkGene(index: curDad)
                }
                
                curDad += 1
            } else if (mom.getLinkGene(index: curMom).getInnovation() == dad.getLinkGene(index: curDad).getInnovation()) {
                if random() < 0.5 {
                    selectedGene = mom.getLinkGene(index: curMom)
                } else {
                    selectedGene = dad.getLinkGene(index: curDad)
                }
                curMom += 1
                curDad += 1
            }
            
            if babyLinkGenes.isEmpty {
                babyLinkGenes += [selectedGene]
            } else {
                if babyLinkGenes[babyLinkGenes.count - 1].getInnovation() != selectedGene.getInnovation() {
                    babyLinkGenes += [selectedGene]
                    
                }
            }
            
            if !neuronIDs.contains(selectedGene.getFrom()) {
                neuronIDs += [selectedGene.getFrom()]
            }
            
            if !neuronIDs.contains(selectedGene.getTo()) {
                neuronIDs += [selectedGene.getTo()]
            }
            
        }// end while
        
        
        
        //neuronIDs += [mom.getInputCount() + 1]
        
        neuronIDs.sort()
        for id in neuronIDs {
            babyNeuronGenes += [database.getNodeByID(id: id)]
        }
        
        return Genome(id: database.nextGenomeID(), neurons: babyNeuronGenes, links: babyLinkGenes, inputs: mom.getInputCount(), outputs: mom.getOutputCount())
        
    }
    
    func analize(stagnantAge: Int) {
        var sum: Double = 0
        for g in self.organisms {
            sum += g.getFitness()
        }
        self.averageFitness = sum / Double(self.organisms.count)
        if self.averageFitness > self.bestFitness {
            self.bestFitness = self.averageFitness
            // Can reproduce
            self.stagnant = false
            self.ageNoProgress = 0
        } else {
            self.ageNoProgress += 1
        }
        
        if ageNoProgress >= stagnantAge {
            self.stagnant = true
        }
        
    }
    
    func increaseAge() {
        self.age += 1
    }
    
    func sortGenomes() {
        self.organisms.sort { g1, g2 in
            g1.getFitness() > g2.getFitness()
        }
    }
    
    func toString() -> String {
        return "ID: \(self.id), avg fitness: \(self.averageFitness), age: \(self.age), genomes: \(self.getSpawnAmount()), best fitness: \(self.bestFitness)"
    }
    
    
}
