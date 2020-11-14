# NEAT Implementation With Swift

This implementation is based on K.O. Stanley and R. Miikkulainen's paper.
  http://nn.cs.utexas.edu/downloads/papers/stanley.ec02.pdf
  
NEAT stands for Neural Evolution of Augmenting Topologies. Just as our brain uses neurons to interpret information, this algorithm searches spaces minimally by creating new connections competitively until a solution is found.





- If you're creating a Swift executable, you can simply add the package to your app.


**To use NEAT-swift inside of an XCode project:**

- Import the package into your project
![alt text](http://www.troydeville.com/wp-content/uploads/2018/06/neatImport.png)

- Import the module into your chosen file.
```Swift
import Neat
```

- Create a NEAT network.
```Swift
let network = Neat(inputs: 2, outputs: 1, population: 300, confFile: nil, multithread: false)
```
**NOTE**: *"confFile" and "multithread" are not fully functional.
  "confFile" is not functional mostly because of the inability to edit mutation percentages.
  "multithread" is functional, but only for 8 threads (i.e. most quad-core processors).*
  - Support for other thread amounts will be coming soon. For now, 1 thread or 8 threads are supported.
  

**Typical implementation for a single thread NEAT network (network to be tested until a solution is found or close to it).**
```Swift

let network = Neat(inputs: 2, outputs: 1, population: 300, confFile: nil, multithread: false)

let input = [[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]]
let expected = [[0.0], [1.0], [1.0], [0.0]]

let fitnessGoal = 16.0
var generation = 1

var king: NGenome?

let inputCount = input[0].count
let outputCount = expected[0].count

while true {
        
    for _ in 1...network.populationSize {//testing entire population
        
        var sumedTotal = 0.0
        
        // Test the Genome Pool
        for i in 0..<input.count {
            let output = network.run(inputs: input[i], inputCount: inputCount, outputCount: outputCount)
            for o in 0..<output.count {
                sumedTotal += abs(expected[i][o] - output[o])
            }
        }
        
        // Assign genome a fitness score from the test.
        let currentGenomeFitness = pow(sqrt(fitnessGoal) - sumedTotal, 2)
        
        // Next
        network.nextGenomeStepOne(currentGenomeFitness)
    }
        
    // Assign genomes a fitness score from the tests.
    network.nextGenomeStepTwo()
    
    // Do NEAT here.
    network.epoch()
    
    king = network.getKing()
    
    print(network.description)
    
    print("Generation: \(generation)")
    generation += 1
    
    print("King fitness: \(king!.fitness)")
    
    if king!.fitness >= fitnessGoal*0.965 {
        // Print out the description after the solution is found only.
        // Printing out the description before will result in an unpredictable outcome
        print(king!.description)
        break
    }
    
} //end

let fitness = network.testNetwork(genome: king!, inputs: input, expected: expected, inputCount: inputCount, outputCount: outputCount, testType: .distanceSquared, info: true)
print("Fitness: \(fitness)")


```
