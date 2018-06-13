public struct NConfiguration {
    var nodeMutation = 0.1
    var connectionMutation = 0.3
    var weightMutation = 0.8
    var activationMutation = 0.8
    var enableMutation = 0.03
    var disableMutation = 0.01
    var recurrentMutation = 0.0
    var typeMutation = 0.5
    var removeLinkMutation = 0.0 // Keep zero for now
    var weightPerturbation = 0.3
    var activationPerturbation = 0.5
    var triesToFindLink = 100
    var threshHold = 5.0
    var c1 = 1.0
    var c2 = 1.0
    var c3 = 0.08
    var threads = 8
}
