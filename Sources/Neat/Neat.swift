public struct Neat {
    
    public let network: Network
    
    public init(inputs: Int, outputs: Int, population: Int) {
        network = Network(inputs: inputs, outputs: outputs, population: population)
        print("Network initiated.")
    }
    
    // Network's inputs
    public var inputs = [[Double]]()
    
    // Network's Generation Identifier
    public var generation = 0
    
    // Network's King Genome and Fitness Score
    public var king = Genome()
    public var topFitnessScore = 0.0
    
    // Network's Population Control
    public var populationIndexPos: Int = 0
    public var currentFitnessScore = 0.0
    
    // Run the genome
    public mutating func run(input: Double..., snapshot: Bool) -> [Double] {
        var depth: Int = 1
        var lowestPosition: Double = 1000
        for n in network.genomeGetNeuronGenes(index: populationIndexPos) {
            let yPos: Double = n.getYPos()
            if yPos < lowestPosition && yPos > 0 {
                lowestPosition = yPos
            }
        }
        while lowestPosition < 200 {
            lowestPosition *= 2
            depth += 1
        }
        network.genomeCreatePhenotype(genomeIndex: populationIndexPos, depth: depth)
        
        // Output Result
        var runType = RunType.snapshot
        if !snapshot { runType = RunType.active }
        let output = network.update(inputs: input, type: runType, genome: populationIndexPos)
        
        return output
    }
    
    public mutating func compareFitness(logs: Bool) {
        if currentFitnessScore > topFitnessScore {
            topFitnessScore = currentFitnessScore
            if logs { print("FITNESS: \(currentFitnessScore)") }
            if logs { print(network.getGenome(index: populationIndexPos).toString()) }
            let w = network.getGenome(index: populationIndexPos)
            king = Genome(id: w.getID(), neurons: w.getNeuronGenes(), links: w.getLinkGenes(), inputs: w.getInputCount(), outputs: w.getOutputCount())
            king.setFitness(fit: currentFitnessScore)
        }
    }
    
    public mutating func runNext(logs: Bool) {
        // Incriment the population's index position.
        self.network.setGenomeFitness(index: populationIndexPos, fitness: currentFitnessScore)
        self.currentFitnessScore = 0.0
        self.populationIndexPos += 1
        //if logs { print("Genome: \(populationIndexPos)") }
        
        if populationIndexPos == network.populationCount() {
            network.epoch()
            generation += 1
            populationIndexPos = 0
            if logs { print("Generation: \(generation)") }
        }
    }
    
}

public extension Neat {
    
    public func getGeneration() -> Int { return self.generation }
    public func getTopFitnessScore() -> Double { return self.topFitnessScore }
    public func getPopulationIndexPos() -> Int { return self.populationIndexPos }
    
    public func getCurrentFitnessScore() -> Double { return self.currentFitnessScore }
    public mutating func setCurrentFitnessScore(score: Double) { self.currentFitnessScore = score }
    
}





