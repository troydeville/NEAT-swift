import Foundation


public class NDatabase {
    
    var innovationID = 0
    var speciesID = 0
    var genomeID = 0
    var nodeID = 0
    var nodeInnovations: BTree<Int, NNodeInnovation> = BTree(order: BTREEORDER)!
    var linkInnovations: BTree<Int, NLinkInnovation> = BTree(order: BTREEORDER)!
    
    // Variables for configuration file
    var perturbMutation = 0.80
    var addNodeMutation = 0.03
    var addLinkMutation: Double
    var enableMutation = 0.8
    var activationMutation = 0.1
    var typeMutation = 0.01
    
    var perturbAmount = 0.333333333
    var activationPerturbAmount = 0.333333333
    var timesToFindConnection = 10
    
    var population = 0
    
    
    var biasId: Int
    
    init(population: Int, inputs: Int, outputs: Int) {
        self.genomeID = population
        self.nodeID = inputs + outputs + 1
        self.biasId = inputs + 1
        self.population = population
        let x = Double(population)
        self.addLinkMutation = Sigmoid(x: x*x / (x + 1), response: 0.001) - 0.2
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
                var innovation = NLinkInnovation(innovationId: l.innovation, nIn: l.from, nOut: l.to, enabled: l.enabled, weight: l.weight)
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
        let linkInnovation = NLinkInnovation(innovationId: link.innovation, nIn: link.from, nOut: link.to, enabled: link.enabled, weight: link.weight)
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
