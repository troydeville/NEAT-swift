/*
import Foundation

let BTREEORDER = 4

// try and test the genome

print("start\n*******************************\n")

let input = [[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]]
let expected = [0.0, 1.0, 1.0, 0.0]

let url = "/Users/troydeville/Development/NEAT/2018/NEAT/NEAT/neatconf.json"

let xorNetwork = NeuralNetwork(inputs: 2, outputs: 1, population: 150, confURL: url)

// Print the stats.
print("Starting the test.")

let fitnessGoal = 16.0
var ActualFitness = 0.0
var generation = 1
while true {
    
    for i in 1...xorNetwork.populationSize {//testing entire population
        
        var sumedTotal = 0.0
        //var sumedTotal2 = 0.0
        
        // Test the Genome Pool
        for i in 0..<input.count {
            
            let output = xorNetwork.run(inputs: input[i], inputCount: 2, outputCount: 1)
            sumedTotal += abs(expected[i] - output[0])
            //print("input: \(input[i]), output: \(output[0]), expected output: \(expected[i])")
        }
        //print("\n")
        
        let currentGenomeFitness = pow(4 - sumedTotal, 2)
        //print("Last genome's fitness: \(currentGenomeFitness)")
        
        // Assign the fitness score to the genome
        xorNetwork.assignFitness(fitness: currentGenomeFitness)
        
        // add genome to a species
        xorNetwork.assignToSpecies()
        
        if currentGenomeFitness >= fitnessGoal*0.95 {
            ActualFitness = 16
            break
        }
        
        if i == xorNetwork.populationSize {
            //print(xorNetwork.king.description)
            xorNetwork.epoch()
            print(xorNetwork.description)
            
        }
        
    }
    
    
    
    print("Generation: \(generation)")
    
    
    generation += 1
    
    if ActualFitness == 16 {
        break
    }
    
}

print("The KING:\n\(xorNetwork.king.description)")
print("\n\(xorNetwork.description)")



for i in input {
    var network = NNetwork(genome: xorNetwork.findKing())
    let output = network.run(inputsIn: i, networkType: NetworkType.SnapShot)
    print("in: \(i), out: \(output)")
}


print("\n*******************************\ndone")
*/
