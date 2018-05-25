/*
import Foundation

// try and test the genome

print("start\n*******************************\n")

//let input = [[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]]

let input = [
    [0.0, 0.0, 0.0], [0.0, 0.0, 1.0], [0.0, 1.0, 0.0], [0.0, 1.0, 1.0],
    [1.0, 0.0, 0.0], [1.0, 0.0, 1.0], [1.0, 1.0, 0.0], [1.0, 1.0, 1.0]
]

//let expected = [0.0, 1.0, 1.0, 0.0]
let expected = [0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0]

let url = "/Users/troydeville/Development/NEAT/2018/NEAT/NEAT/neatconf.json"

// Print the stats.
print("Starting the test.")

//let fitnessGoal = 64.0
let fitnessGoal = 64.0

var ActualFitness = 0.0
var generation = 1

var KingNetworkID = 0

var networks = [Neat]()
var queues = [DispatchQueue]()

for i in 1...8 {
    networks += [Neat(inputs: 3, outputs: 1, population: 500, confURL: url)]
    queues += [DispatchQueue(label: "NEAT_NETWORK_\(i)/8")]
}

let group = DispatchGroup()

var nObj = [NeatTaskObject]()
for i in 1...8 {
    nObj += [NeatTaskObject(network: networks[i-1])]
}

while true {
    /*
     for _ in 1...xorNetwork.populationSize {//testing entire population
     
     var sumedTotal = 0.0
     
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
     
     if currentGenomeFitness > ActualFitness {
     ActualFitness = currentGenomeFitness
     }
     
     if ActualFitness >= fitnessGoal*0.97 {
     break
     }
     
     }
     */
    
    for i in 0..<queues.count {
        queues[i].async(group: group) {
            nObj[i].task(networkId: i + 1)
            /*
             DispatchQueue.global(qos: .userInitiated).async {
             //print("task \(i + 1) done.")
             }
             */
        }
    }
    
    while !nObj[0].taskComplete || !nObj[1].taskComplete || !nObj[2].taskComplete || !nObj[3].taskComplete || !nObj[4].taskComplete || !nObj[5].taskComplete || !nObj[6].taskComplete || !nObj[7].taskComplete {}
    
    
    //xorNetwork1.epoch()
    //print(xorNetwork.description)
    print("Generation: \(generation)")
    generation += 1
    if ActualFitness >= fitnessGoal*0.97 { break }
    
} //end

var highestFitness = 0.0
var winnerNetwork: Neat
if KingNetworkID == 0 {
    winnerNetwork = networks[KingNetworkID]
} else {
    winnerNetwork = networks[KingNetworkID - 1]
}
for network in networks {
    if network.findKing().fitness >= fitnessGoal*0.97 {
        winnerNetwork = network
    }
}

//let winnerNetwork = networks[KingNetworkID]

print("The KING:\n\(winnerNetwork.king.description)")
print("\n\(winnerNetwork.description)")



for i in input {
    var network = NNetwork(genome: winnerNetwork.findKing())
    let output = network.run(inputsIn: i, networkType: NetworkType.SnapShot)
    print("in: \(i), out: \(output)")
}


print("\n*******************************\ndone")
*/
/*

import Foundation

// try and test the genome

print("start\n*******************************\n")

let input: [[Double]] = [
    [0.0, 0.0, 0.0], [0.0, 0.0, 1.0], [0.0, 1.0, 0.0], [0.0, 1.0, 1.0],
    [1.0, 0.0, 0.0], [1.0, 0.0, 1.0], [1.0, 1.0, 0.0], [1.0, 1.0, 1.0]
]

//let input = [[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]]


let expected: [[Double]] = [
    [0.0], [0.0], [0.0], [0.0],
    [0.0], [0.0], [0.0], [1.0]
]


//let expected = [[0.0], [1.0], [1.0], [0.0]]

let url = "/Users/troydeville/Development/NEAT/2018/NEAT/NEAT/neatconf.json"

// Print the stats.
print("Starting the test.")

let nnn = Double(expected.count * expected.first!.count)

let fitnessGoal: Double = pow(nnn, 2)
var HighestFitness = 0.0
var generation = 1

let population = 400


let inputs = input.first!.count
let outputs = expected.first!.count

var king: NGenome?

if population % 8 != 0 { fatalError() }

// create network
let network = Neat(inputs: inputs, outputs: outputs, population: population, confURL: url, multithread: true)

while true {
    
    network.run(inputs: input, expected: expected, inputCount: inputs, outputCount: outputs)
    print("Generation \(generation) run complete.")
    
    king = network.getKing()
    
    if king!.fitness >= fitnessGoal*0.97 {
        print(king!.description)
        break
    }
    
    generation += 1
    
} //end

network.testNetwork(genome: king!, inputs: input, expected: expected, inputCount: inputs, outputCount: outputs)


print("Generation: \(generation)")






//let winnerNetwork = networks[KingNetworkID]

//print("The KING:\n\(xorNetwork.king.description)")
//print("\n\(xorNetwork.description)")


/*
 for i in input {
 var network = NNetwork(genome: xorNetwork.findKing())
 let output = network.run(inputsIn: i, networkType: NetworkType.SnapShot)
 print("in: \(i), out: \(output)")
 }
 */

print("\n*******************************\ndone")
/*
 while true {
 
 for _ in 1...xorNetwork.populationSize {//testing entire population
 
 var sumedTotal = 0.0
 
 // Test the Genome Pool
 for i in 0..<input.count {
 let output = xorNetwork.run(inputs: input[i], inputCount: inputs, outputCount: outputs)
 sumedTotal += abs(expected[i] - output[0])
 }
 
 let currentGenomeFitness = pow(4 - sumedTotal, 2)       // Assign genome a fitness score from the test.
 
 // conditions
 if currentGenomeFitness > ActualFitness { ActualFitness = currentGenomeFitness }
 if ActualFitness >= fitnessGoal*0.99 { break }
 
 
 xorNetwork.nextGenome(currentGenomeFitness)             // Next.
 }
 
 xorNetwork.epoch()
 print(xorNetwork.description)
 print("Generation: \(generation)")
 generation += 1
 
 if ActualFitness >= fitnessGoal*0.99 { print("Winning Fitness Score: \(ActualFitness)"); break }
 
 } //end
 */
*/
