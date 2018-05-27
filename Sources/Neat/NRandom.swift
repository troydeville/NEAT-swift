import Foundation

public func normalRandom() -> Double {
    #if os(Linux)
    return 2 * Double(random()) / Double(UINT32_MAX)
    #else
    return (Double(arc4random()) / Double(UINT32_MAX))
    #endif
    
}

public func NRandom() -> Double {
    if normalRandom() < 0.5 {
        return normalRandom() * 1
    } else {
        return normalRandom() * -1.0
    }
}

public func randomInt(min: Int, max: Int) -> Int {
    if max < 0 {
        return 0
    }
    #if os(Linux)
    return min + Int(random() % (max - min))
    #else
    return min + Int(arc4random_uniform(UInt32(max - min)))
    #endif
    
}


public func NRandomActivationType() -> NActivation {
    switch randomInt(min: 1, max: 7) {
    case 1:
        return NActivation.add
    case 2:
        return NActivation.sigmoid
    case 3:
        return NActivation.tanh
    case 4:
        return NActivation.relu
    case 5:
        return NActivation.sine
    case 6:
        return NActivation.abs
    case 7:
        return NActivation.square
    default: return NActivation.sigmoid
    }
}

/*
 public func NRandomActivationType() -> NActivation {
 switch randomInt(min: 1, max: 7) {
 case 1:
 return NActivation.sigmoid
 case 2:
 return NActivation.sigmoid
 case 3:
 return NActivation.sigmoid
 case 4:
 return NActivation.sigmoid
 case 5:
 return NActivation.sigmoid
 case 6:
 return NActivation.sigmoid
 case 7:
 return NActivation.sigmoid
 default: return NActivation.sigmoid
 }
 }
 */
