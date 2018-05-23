import Foundation

public enum NActivation {
    case add
    case sigmoid
    case tanh
    case relu
    case sine
    case abs
    case square
}


public func Add(x: Double, response: Double) -> Double {
    return x + response
}

public func Sigmoid(x: Double, response: Double) -> Double {
    return 1 / (1 + exp((-5 * response) * x))
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
    return abs(sin(x * response))
}

public func Abs(x: Double, response: Double) -> Double {
    return abs(x * response)
}

public func Square(x: Double, response: Double) -> Double {
    return x * x * response
}

public func SigmoidS(x: Double, response: Double) -> Double {
    //return (sinh(x + response) / cosh(x + response))
    return 1 / (1 + exp(5 * response * x))
    //return sin(response * x)
}
