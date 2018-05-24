import Foundation
/*
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

let fitnessGoal = 64.0
var ActualFitness = 0.0
var generation = 1

var KingNetworkID = 0

var networks = [Neat]()
var queues = [DispatchQueue]()

for i in 1...8 {
    networks += [Neat(inputs: 3, outputs: 1, population: 150, confURL: url)]
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
    
}
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
public class NeatTaskObject {
    
    public var taskComplete = false
    public var value = 0
    var network: Neat
    
    init(network: Neat) { self.network = network }
    
    
    public func task(networkId: Int) {
        
        self.taskComplete = false
        
        switch networkId {
        case 1:
            network = networks[0]
        case 2:
            network = networks[1]
        case 3:
            network = networks[2]
        case 4:
            network = networks[3]
        case 5:
            network = networks[4]
        case 6:
            network = networks[5]
        case 7:
            network = networks[6]
        case 8:
            network = networks[7]
        default: break
            
        }
        
        for _ in 1...network.populationSize {//testing entire population
            
            var sumedTotal = 0.0
            
            // Test the Genome Pool
            for i in 0..<input.count {
                let output = network.run(inputs: input[i], inputCount: 3, outputCount: 1)
                sumedTotal += abs(expected[i] - output[0])
                //print("input: \(input[i]), output: \(output[0]), expected output: \(expected[i])")
            }
            //print("\n")
            
            let currentGenomeFitness = pow(8 - sumedTotal, 2)
            //print("Last genome's fitness: \(currentGenomeFitness)")
            
            // Assign the fitness score to the genome
            network.assignFitness(fitness: currentGenomeFitness)
            
            // add genome to a species
            network.assignToSpecies()
            
            if currentGenomeFitness > ActualFitness {
                ActualFitness = currentGenomeFitness
                print(network.description)
            }
            
            if ActualFitness >= fitnessGoal*0.97 {
                KingNetworkID = networkId
                break
            }
            
        }
        network.epoch()
        self.taskComplete = true
    }
    
}
*/
