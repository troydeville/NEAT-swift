import Foundation

public let PI = 3.14159265358979323846264338327950288419717

public enum NActivation {
    case add
    case sigmoid
    case tanh
    case relu
    case sine
    case abs
    case square
    case cube
    case gauss
    case clamped
    case hat
    case sinh
    case sech
}

public func Add(x: Double, response: Double) -> Double {
    return x * response
}

public func Sigmoid(x: Double, response: Double) -> Double {
    return 1 / (1 + exp((-4.9 * response) * x))
}

public func Tanh(x: Double, response: Double) -> Double {
    return tanh(x*response)
}

public func Relu(x: Double, response: Double) -> Double {
    if x <= 0.0 {
        return 0.0
    }
    return x * response
}

public func Sine(x: Double, response: Double) -> Double {
    return sin(x*response)
}

public func Abs(x: Double, response: Double) -> Double {
    return abs(x * response)
}

public func Square(x: Double, response: Double) -> Double {
    return x * x * response
}

public func Cube(x: Double, response: Double) -> Double {
    return x * x * x * response
}

public func Exp(x: Double, response: Double) -> Double {
    return exp(x*response)
}

public func Gauss(x: Double, response: Double) -> Double {
    return (1 / sqrt(2*PI)) * exp((-1/2)*(x-response)*(x-response))
}

public func Clamped(x: Double, response: Double) -> Double {
    if x < (-1 * response) {
        return -1 * response
    } else if x > (1 * response) {
        return 1 * response
    }
    return x * response
}

public func Hat(x: Double, response: Double) -> Double {
    if x < (-1 * response) {
        return 0
    } else if x > (1 * response) {
        return 0
    }
    return x * response
}

public func Sinh(x: Double, response: Double) -> Double {
    return sinh(x / response)
}

public func Sech(x: Double, response: Double) -> Double {
    return 1 / cosh(x * response)
}
