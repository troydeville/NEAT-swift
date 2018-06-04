import Foundation


public class NDatabase {
    
    var innovationID = 0
    var speciesID = 0
    var genomeID = 0
    var nodeID = 0
    var nodeInnovations: BTree<Int, NNodeInnovation> = BTree(order: BTREEORDER)!
    var linkInnovations: BTree<Int, NLinkInnovation> = BTree(order: BTREEORDER)!
    
    let perturbMutation: Double
    let addNodeMutation: Double
    let addLinkMutation: Double
    let enableMutation: Double
    let disableMutation: Double
    let activationMutation: Double
    let typeMutation: Double
    let recurrentMutation: Double
    let removeLinkMutation: Double
    
    var threshHold: Double
    let c1: Double
    let c2: Double
    let c3: Double
    
    
    var perturbAmount: Double
    var activationPerturbAmount: Double
    var timesToFindConnection: Double
    
    var population = 0
    
    
    var biasId: Int
    
    init(population: Int, inputs: Int, outputs: Int, config: [String:Double]) {
        
        print(config)
        
        self.genomeID = population
        self.nodeID = inputs + outputs + 1
        self.biasId = inputs + 1
        self.population = population
        //let x = Double(population)
        //self.addLinkMutation = Sigmoid(x: x*x / (x + 1), response: 0.001) - 0.4
        
        /*
         "nodeMutation": 0.01,
         "connectionMutation": 0.5,
         "weightMutation": 0.80,
         "activationMutation": 0.1,
         "enableMutation": 0.3,
         "weightPerturbation": 0.3,
         "activationPerturbation": 1,
         "threshHold": 7.5,
         "c1": 1.0,
         "c2": 1.0,
         "c3": 0.00001,
         "threads": 8
         */
        
        // Variables for configuration file
        self.addNodeMutation = config["nodeMutation"]!
        self.addLinkMutation = config["connectionMutation"]!
        self.perturbMutation = config["weightMutation"]!
        self.activationMutation = config["activationMutation"]!
        self.enableMutation = config["enableMutation"]!
        self.disableMutation = config["disableMutation"]!
        self.typeMutation = config["typeMutation"]!
        self.recurrentMutation = config["recurrentMutation"]!
        self.removeLinkMutation = config["removeLinkMutation"]!
        
        self.perturbAmount = config["weightMutation"]!
        self.activationPerturbAmount = config["activationPerturbation"]!
        self.timesToFindConnection = config["triesToFindLink"]!
        
        self.threshHold = config["threshHold"]!
        self.c1 = config["c1"]!
        self.c2 = config["c2"]!
        self.c3 = config["c3"]!
        
    }
    
    func newInnovation(node: NNode?, link: NLink?) -> Bool {
        
        if let n = node {
            // determine if node exists
            if nodeInnovations.value(for: n.id) == nil {
                var innovation = NNodeInnovation(nodeId: n.id)
                innovation.setInnovation(innovationId: self.nextInnovation())
                nodeInnovations.insert(innovation, for: n.id)
            } else {
                return false
            }
        } else if let l = link {
            // determine if link exists
            if linkInnovations.value(for: l.innovation) == nil {
                var innovation = NLinkInnovation(innovationId: l.innovation, nIn: l.from, nOut: l.to, enabled: l.enabled, weight: l.weight, recurrent: l.recurrent)
                innovation.setInnovation(innovationID: self.nextInnovation())
                linkInnovations.insert(innovation, for: l.innovation)
            } else {
                return false
            }
        } else { print("No input node or link..."); return false }
        
        
        return true
    }
    
    func nextInnovation() -> Int {
        self.innovationID += 1
        return self.innovationID
    }
    
    func insertLink(link: NLink) {
        let linkInnovation = NLinkInnovation(innovationId: link.innovation, nIn: link.from, nOut: link.to, enabled: link.enabled, weight: link.weight, recurrent: link.recurrent)
        self.linkInnovations.insert(linkInnovation, for: link.innovation)
    }
    
    func nextSpeciesId() -> Int {
        self.speciesID += 1
        return self.speciesID
    }
    
    func nextGenomeId() -> Int {
        self.genomeID += 1
        return self.genomeID
    }
    
    func nextNodeId() -> Int {
        self.nodeID += 1
        return self.nodeID
    }
    
    func getInnovationId(link: NLink) -> Int {
        return self.linkInnovations.value(for: link.innovation)!.innovationID
    }
    
    func getLinkDataFromComparison(nodeFrom: Int, nodeTo: Int) -> [Int] {
        //let linkIds = self.linkInnovations.inorderArrayFromKeys
        
        var nodesToCheck = [Int]()
        
        var linksFrom = [NLinkInnovation]()
        var linksTo = [NLinkInnovation]()
        /*
         for key in linkIds {
         let linkInov = self.linkInnovations.value(for: key)!
         if linkInov.nIn == nodeFrom {
         linksFrom += [linkInov]
         }
         }
         
         for key in linkIds {
         let linkInov = self.linkInnovations.value(for: key)!
         if linkInov.nOut == nodeTo {
         linksTo += [linkInov]
         }
         }
         */
        self.linkInnovations.traverseKeysInOrder { key in
            
            let linkInov1 = self.linkInnovations.value(for: key)!
            if linkInov1.nIn == nodeFrom {
                linksFrom += [linkInov1]
            }
            
            let linkInov2 = self.linkInnovations.value(for: key)!
            if linkInov2.nOut == nodeTo {
                linksTo += [linkInov2]
            }
        }
        
        for link in linksFrom {
            nodesToCheck += [link.nOut]
        }
        
        for link in linksTo {
            nodesToCheck += [link.nIn]
        }
        
        nodesToCheck = sortAndKeepDuplicates(nodesToCheck)
        
        return nodesToCheck
    }
    
    func getLink(innovation: Int) -> NLink {
        if self.linkInnovations.value(for: innovation) != nil {// Innovation exists.
            
            let link = self.linkInnovations.value(for: innovation)!
            return NLink(innovation: link.innovationID, to: link.nOut, from: link.nIn, weight: link.weight, enabled: link.enabled, recurrent: link.recurrent)
            
        } else { fatalError() }
    }
    
    func getInnovationId(from: Int, to: Int) -> Int {
        //let linkKeys = self.linkInnovations.inorderArrayFromKeys
        
        var linkIdentification = -1
        var search = true
        self.linkInnovations.traverseKeysInOrder { key in
            if search {
                let link = self.linkInnovations.value(for: key)!
                if (link.nIn == from) && (link.nOut == to) { // Innovation exists
                    linkIdentification = link.innovationID
                    search = false
                }
            }
        }
        /*
         for key in linkKeys {
         let link = self.linkInnovations.value(for: key)!
         if (link.nIn == from) && (link.nOut == to) { // Innovation exists
         return link.innovationID
         }
         }
         */
        return linkIdentification
    }
    
}

// MARK: NDatabase extension: Decription

extension NDatabase: CustomStringConvertible {
    /**
     *  Returns details of the database
     */
    public var description: String {
        //let nodeKeys = self.nodeInnovations.inorderArrayFromKeys
        var innovationIds = [Int]()
        
        self.nodeInnovations.traverseKeysInOrder { key in
            innovationIds += [self.nodeInnovations.value(for: key)!.innovationId]
        }
        /*
         for nKey in nodeKeys {
         innovationIds += [self.nodeInnovations.value(for: nKey)!.innovationId]
         }
         */
        
        //let linkKeys = self.linkInnovations.inorderArrayFromKeys
        
        self.linkInnovations.traverseKeysInOrder { key in
            innovationIds += [self.linkInnovations.value(for: key)!.innovationID]
        }
        /*
         for lKey in linkKeys {
         innovationIds += [self.linkInnovations.value(for: lKey)!.innovationID]
         }
         */
        return "\(innovationIds)"
    }
}
