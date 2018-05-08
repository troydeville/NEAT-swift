public struct Neat {
    
    public let network: Network
    
    public init(inputs: Int, outputs: Int, population: Int) {
        network = Network(inputs: inputs, outputs: outputs, population: population)
    }
    
    // Network's inputs
    var inputs = [[Double]]()
    
    // Network's Generation Identifier
    var generation = 0
    
    // Network's King Genome and Fitness Score
    var king = Genome()
    var topFitnessScore = 0.0
    
    // Network's Population Control
    var populationIndexPos: Int = 0
    var currentFitnessScore = 0.0
    
    public mutating func run(input: Double..., continuous: Bool, logs: Bool) -> [Double] {
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
        let output = network.update(inputs: input, type: RunType.snapshot, genome: populationIndexPos)
        
        if !continuous {
            // Incriment the population's index position.
            self.network.setGenomeFitness(index: populationIndexPos, fitness: currentFitnessScore)
            self.currentFitnessScore = 0.0
            self.populationIndexPos += 1
            if logs { print("Genome: \(populationIndexPos)") }
            
            if populationIndexPos == network.populationCount() {
                network.epoch()
                generation += 1
                populationIndexPos = 0
                if logs { print("Generation: \(generation)") }
            }
            
        }
        
        return output
    }
    
}
