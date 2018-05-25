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
 import Neat
 import Dispatch
 
 // try and test the genome
 
 print("start\n*******************************\n")
 
 let rawInput: [[Double]] = [
 [5.1,3.5,1.4,0.2], [4.9,3.0,1.4,0.2], [4.7,3.2,1.3,0.2], [4.6,3.1,1.5,0.2], [5.0,3.6,1.4,0.2], [5.4,3.9,1.7,0.4], [4.6,3.4,1.4,0.3], [5.0,3.4,1.5,0.2], [4.4,2.9,1.4,0.2], [4.9,3.1,1.5,0.1], [5.4,3.7,1.5,0.2], [4.8,3.4,1.6,0.2], [4.8,3.0,1.4,0.1], [4.3,3.0,1.1,0.1], [5.8,4.0,1.2,0.2], [5.7,4.4,1.5,0.4], [5.4,3.9,1.3,0.4], [5.1,3.5,1.4,0.3], [5.7,3.8,1.7,0.3], [5.1,3.8,1.5,0.3], [5.4,3.4,1.7,0.2], [5.1,3.7,1.5,0.4], [4.6,3.6,1.0,0.2], [5.1,3.3,1.7,0.5], [4.8,3.4,1.9,0.2], [5.0,3.0,1.6,0.2], [5.0,3.4,1.6,0.4], [5.2,3.5,1.5,0.2], [5.2,3.4,1.4,0.2], [4.7,3.2,1.6,0.2], [4.8,3.1,1.6,0.2], [5.4,3.4,1.5,0.4], [5.2,4.1,1.5,0.1], [5.5,4.2,1.4,0.2], [4.9,3.1,1.5,0.1], [5.0,3.2,1.2,0.2], [5.5,3.5,1.3,0.2], [4.9,3.1,1.5,0.1], [4.4,3.0,1.3,0.2], [5.1,3.4,1.5,0.2], [5.0,3.5,1.3,0.3], [4.5,2.3,1.3,0.3], [4.4,3.2,1.3,0.2], [5.0,3.5,1.6,0.6], [5.1,3.8,1.9,0.4], [4.8,3.0,1.4,0.3], [5.1,3.8,1.6,0.2], [4.6,3.2,1.4,0.2], [5.3,3.7,1.5,0.2], [5.0,3.3,1.4,0.2], [7.0,3.2,4.7,1.4], [6.4,3.2,4.5,1.5], [6.9,3.1,4.9,1.5], [5.5,2.3,4.0,1.3], [6.5,2.8,4.6,1.5], [5.7,2.8,4.5,1.3], [6.3,3.3,4.7,1.6], [4.9,2.4,3.3,1.0], [6.6,2.9,4.6,1.3], [5.2,2.7,3.9,1.4], [5.0,2.0,3.5,1.0], [5.9,3.0,4.2,1.5], [6.0,2.2,4.0,1.0], [6.1,2.9,4.7,1.4], [5.6,2.9,3.6,1.3], [6.7,3.1,4.4,1.4], [5.6,3.0,4.5,1.5], [5.8,2.7,4.1,1.0], [6.2,2.2,4.5,1.5], [5.6,2.5,3.9,1.1], [5.9,3.2,4.8,1.8], [6.1,2.8,4.0,1.3], [6.3,2.5,4.9,1.5], [6.1,2.8,4.7,1.2], [6.4,2.9,4.3,1.3], [6.6,3.0,4.4,1.4], [6.8,2.8,4.8,1.4], [6.7,3.0,5.0,1.7], [6.0,2.9,4.5,1.5], [5.7,2.6,3.5,1.0], [5.5,2.4,3.8,1.1], [5.5,2.4,3.7,1.0], [5.8,2.7,3.9,1.2], [6.0,2.7,5.1,1.6], [5.4,3.0,4.5,1.5], [6.0,3.4,4.5,1.6], [6.7,3.1,4.7,1.5], [6.3,2.3,4.4,1.3], [5.6,3.0,4.1,1.3], [5.5,2.5,4.0,1.3], [5.5,2.6,4.4,1.2], [6.1,3.0,4.6,1.4], [5.8,2.6,4.0,1.2], [5.0,2.3,3.3,1.0], [5.6,2.7,4.2,1.3], [5.7,3.0,4.2,1.2], [5.7,2.9,4.2,1.3], [6.2,2.9,4.3,1.3], [5.1,2.5,3.0,1.1], [5.7,2.8,4.1,1.3], [6.3,3.3,6.0,2.5], [5.8,2.7,5.1,1.9], [7.1,3.0,5.9,2.1], [6.3,2.9,5.6,1.8], [6.5,3.0,5.8,2.2], [7.6,3.0,6.6,2.1], [4.9,2.5,4.5,1.7], [7.3,2.9,6.3,1.8], [6.7,2.5,5.8,1.8], [7.2,3.6,6.1,2.5], [6.5,3.2,5.1,2.0], [6.4,2.7,5.3,1.9], [6.8,3.0,5.5,2.1], [5.7,2.5,5.0,2.0], [5.8,2.8,5.1,2.4], [6.4,3.2,5.3,2.3], [6.5,3.0,5.5,1.8], [7.7,3.8,6.7,2.2], [7.7,2.6,6.9,2.3], [6.0,2.2,5.0,1.5], [6.9,3.2,5.7,2.3], [5.6,2.8,4.9,2.0], [7.7,2.8,6.7,2.0], [6.3,2.7,4.9,1.8], [6.7,3.3,5.7,2.1], [7.2,3.2,6.0,1.8], [6.2,2.8,4.8,1.8], [6.1,3.0,4.9,1.8], [6.4,2.8,5.6,2.1], [7.2,3.0,5.8,1.6], [7.4,2.8,6.1,1.9], [7.9,3.8,6.4,2.0], [6.4,2.8,5.6,2.2], [6.3,2.8,5.1,1.5], [6.1,2.6,5.6,1.4], [7.7,3.0,6.1,2.3], [6.3,3.4,5.6,2.4], [6.4,3.1,5.5,1.8], [6.0,3.0,4.8,1.8], [6.9,3.1,5.4,2.1], [6.7,3.1,5.6,2.4], [6.9,3.1,5.1,2.3], [5.8,2.7,5.1,1.9], [6.8,3.2,5.9,2.3], [6.7,3.3,5.7,2.5], [6.7,3.0,5.2,2.3], [6.3,2.5,5.0,1.9], [6.5,3.0,5.2,2.0], [6.2,3.4,5.4,2.3], [5.9,3.0,5.1,1.8],
 ]
 
 var A = 10000000.0
 var B = 0.0
 
 for x in rawInput {
 for i in x {
 if i < A {
 A = i
 }
 if i > B {
 B = i
 }
 }
 }
 
 let a = 0.0
 let b = 1.0
 
 var input: [[Double]] = []
 
 for x in 0..<rawInput.count {
 input += [rawInput[x]]
 for i in 0..<rawInput[x].count {
 let temp = rawInput[x][i]
 input[x][i] = a+(temp-A)*(b-a)/(B-A)
 }
 }
 
 print(input.count)
 
 let expected: [[Double]] = [
 [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0],
 [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0],
 [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0], [0.0, 0.0, 1.0],
 ]
 
 
 //let expected = [[0.0], [1.0], [1.0], [0.0]]
 
 let url = "/Users/troydeville/Development/NEAT/2018/NEAT/NEAT/neatconf.json"
 
 // Print the stats.
 print("Starting the test.")
 
 let nnn = Double(expected.count * expected.first!.count)
 
 let fitnessGoal: Double = 1
 print(nnn)
 var HighestFitness = 0.0
 var generation = 1
 
 let population = 152
 
 
 let inputs = input.first!.count
 let outputs = expected.first!.count
 
 var king: NGenome?
 
 if population % 8 != 0 { fatalError() }
 
 // create network
 let network = Neat(inputs: inputs, outputs: outputs, population: population, confURL: url, multithread: true)
 
 while true {
 
 network.run(inputs: input, expected: expected, inputCount: inputs, outputCount: outputs, testType: .distance)
 print("Generation \(generation) run complete.")
 
 king = network.getKing()
 
 if king!.fitness >= fitnessGoal*0.97 {
 print(king!.description)
 break
 }
 
 generation += 1
 
 } //end
 
 network.testNetwork(genome: king!, inputs: input, expected: expected, inputCount: inputs, outputCount: outputs, testType: .distance)
 
 
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
