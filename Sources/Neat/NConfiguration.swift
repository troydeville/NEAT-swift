public struct NConfiguration {
    public var nodeMutation = 0.1
    public var connectionMutation = 0.3
    public var weightMutation = 0.8
    public var activationMutation = 0.8
    public var enableMutation = 0.03
    public var disableMutation = 0.01
    public var recurrentMutation = 0.0
    public var typeMutation = 0.5
    public var removeLinkMutation = 0.0 // Keep zero for now
    public var weightPerturbation = 0.3
    public var activationPerturbation = 0.5
    public var triesToFindLink = 100
    public var threshHold = 5.0
    public var c1 = 1.0
    public var c2 = 1.0
    public var c3 = 0.08
    public var threads = 8

    public init() {}
}
