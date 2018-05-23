import Foundation

func normalRandom() -> Double {
    return (Double(arc4random()) / Double(UINT32_MAX))
}

// Random value from -1 to 1.
public func NRandom() -> Double {
    if normalRandom() < 0.5 {
        return normalRandom() * 2
    } else {
        return normalRandom() * -1.0 * 2
    }
}

public func randomInt(min: Int, max: Int) -> Int {
    if max < 0 {
        return 0
    }
    return min + Int(arc4random_uniform(UInt32(max - min)))
}

public func NRandomActivationType() -> NActivation {
    switch randomInt(min: 1, max: 7) {
    case 1:
        return NActivation.add
        //return NActivation.sigmoid
    case 2:
        return NActivation.sigmoid
    case 3:
        return NActivation.tanh
        //return NActivation.sigmoid
    case 4:
        return NActivation.relu
        //return NActivation.sigmoid
    case 5:
        return NActivation.sine
        //return NActivation.sigmoid
    case 6:
        return NActivation.abs
    case 7:
        return NActivation.square
        //return NActivation.sigmoid
    default: return NActivation.sigmoid
    }
}

/*
 public func NRandomActivationType() -> NActivation {
    switch randomInt(min: 1, max: 7) {
    case 1:
        return NActivation.relu
    case 2:
        return NActivation.relu
    case 3:
        return NActivation.relu
    case 4:
        return NActivation.relu
    case 5:
        return NActivation.relu
    case 6:
        return NActivation.relu
    case 7:
        return NActivation.relu
    default: return NActivation.relu
    }
 }
*/
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
