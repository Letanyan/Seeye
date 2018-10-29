//
//  GATests.swift
//  SeeyeTests
//
//  Created by Letanyan Arumugam on 2018/10/29.
//

import XCTest
@testable import Seeye

struct PoloynomialChromosome: Chromosome, CustomStringConvertible {
  var polynomial: [Double]
  
  init(_ coeff: [Double], _ geneSpace: Range<Double>) {
    polynomial = coeff
    _geneSpace = geneSpace
  }
  
  var description: String {
    return polynomial.description
  }
  
  func randomGene() -> Double {
    return .random(in: _geneSpace)
  }
  
  subscript(index: Int) -> Double {
    get {
      return polynomial[index]
    }
    set(value) {
      polynomial[index] = value
    }
  }
  
  var count: Int { return polynomial.count }
  
  var _geneSpace: Range<Double>
  var geneSpace: Range<Double> {
    get {
      return _geneSpace
    }
    set {
      _geneSpace = newValue
    }
  }
}

class GATests: XCTestCase {
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testDefaultEvolutionPerformance() {
    let goal = PoloynomialChromosome([0.1, 20, 0.3, 40], 0..<1)
    
    let ps = (1...20).map { (Int) -> PoloynomialChromosome in
      let r = -100.0..<100.0
      return PoloynomialChromosome([.random(in: r), .random(in: r), .random(in: r), .random(in: r)], r)
    }
    
    var selector = NaturalSelector(population: ps) { chromosome in
      let a = (chromosome[0] - goal[0])
      let b = (chromosome[1] - goal[1])
      let c = (chromosome[2] - goal[2])
      let d = (chromosome[3] - goal[3])
      
      return 1 / (a * a + b * b + c * c + d * d)
    }
    
    self.measure {
      selector.evolvePopulation(numberOfGenerations: 1000)
    }
  }
  
}
