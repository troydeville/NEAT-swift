public func sortAndRemoveDuplicates<T: Comparable>(_ array: [T]) -> [T] {
    var sortedArray = array
    var sortedArrayWithNoDuplicates = [T]()
    sortedArray.sort()
    
    for t in sortedArray {
        if !sortedArrayWithNoDuplicates.contains(t) {
            sortedArrayWithNoDuplicates += [t]
        }
    }
    
    return sortedArrayWithNoDuplicates
}

public func sortAndKeepDuplicates<T: Comparable>(_ array: [T]) -> [T] {
    var sortedArray = array
    var sortedArrayWithOnlyDuplicates = [T]()
    
    while sortedArray.count > 0 {
        let i = sortedArray.removeFirst()
        if sortedArray.contains(i) {
            sortedArrayWithOnlyDuplicates += [i]
            break
        }
    }
    
    return sortedArrayWithOnlyDuplicates
}
