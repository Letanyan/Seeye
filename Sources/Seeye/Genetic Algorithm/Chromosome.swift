import Swift

protocol Chromosome {
  associatedtype Gene
  
  func randomGene() -> Gene
  subscript(index: Int) -> Gene { get set }
  var count: Int { get }
}

extension Chromosome {
  mutating func mutate(withProbability p: Double) {
    for i in 0..<count {
      if .random(in: 0..<1) < p {
        self[i] = randomGene()
      }
    }
  }
  
  mutating func uniformCrossover(with other: Self) {
    precondition(other.count == count)
    
    for i in 0..<count {
      if .random() {
        self[i] = other[i]
      }
    }
  }
  
  mutating func onePointCrossover(with other: Self) {
    precondition(other.count == count)
    
    let point = Int.random(in: 0...count)
    for i in point..<count {
      self[i] = other[i]
    }
  }
  
  mutating func twoPointCrossover(with other: Self) {
    precondition(other.count == count)
    
    let p1 = Int.random(in: 0...count)
    let p2 = p1 + 1 < count ? Int.random(in: (p1 + 1)...count) : count
    for i in p1..<p2 {
      self[i] = other[i]
    }
  }
}
