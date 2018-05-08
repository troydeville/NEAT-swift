import Darwin

public struct Neat {
    
    let network: Network
    
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
    
}
