//
//  NaturalSelector.swift
//  Seeye
//
//  Created by Letanyan Arumugam on 2018/10/29.
//

import Swift

struct NaturalSelector<C: Chromosome> {
  var population: [C]
  var fitness: (C) -> Double
  
  init(population: [C], fitness: @escaping (C) -> Double) {
    self.population = population
    self.fitness = fitness
  }
}

extension NaturalSelector {
  enum SelectionMethod {
    case tournament(groupSize: Int), fitnessProportinate, random
  }
  
  func tournamentSelection(ofSize k: Int) -> C {
    precondition(!population.isEmpty)
    
    var result = [C]()
    result.reserveCapacity(k)
    
    for _ in 0..<k {
      result.append(population.randomElement()!)
    }
    
    return result.max { fitness($0) > fitness($1) }!
  }
  
  func fitnessProportinateSelection() -> C {
    precondition(!population.isEmpty)
    
    let fitnesses = population.map { fitness($0) }
    let total = fitnesses.reduce(0, +)
    let mostFit = fitnesses.max { $0 > $1 }!
    
    let randProb = Double.random(in: 0..<(mostFit / total))
    var choice: C? = nil
    while choice == nil {
      let c = population.randomElement()!
      if fitness(c) / total > randProb {
        choice = c
      }
    }
    return choice!
  }
  
  func randomSelection() -> C {
    precondition(!population.isEmpty)
    return population.randomElement()!
  }
  
  func select(using method: SelectionMethod) -> C {
    switch method {
    case let .tournament(groupSize: k): return tournamentSelection(ofSize: k)
    case .fitnessProportinate: return fitnessProportinateSelection()
    case .random: return randomSelection()
    }
  }
}

extension NaturalSelector {
  enum CrossoverStyle {
    case onePoint, twoPoint, uniform
  }
  
  func crossoveredPopulation(
    using style: CrossoverStyle,
    with method: SelectionMethod
    ) -> [C] {
    var result = [C]()
    result.reserveCapacity(population.count)
    for _ in 0..<population.count {
      let a = select(using: method)
      var child = select(using: method)
      switch style {
      case .onePoint: child.onePointCrossover(with: a)
      case .twoPoint: child.twoPointCrossover(with: a)
      case .uniform: child.uniformCrossover(with: a)
      }
      result.append(child)
    }
    return result
  }
  
  func mutatedPopulation(withProbability p: Double) -> [C] {
    var result = [C]()
    result.reserveCapacity(population.count)
    for var chromosome in population {
      chromosome.mutate(withProbability: p)
      result.append(chromosome)
    }
    return result
  }
}

extension NaturalSelector {
  mutating func fittest() -> C {
    population.sort { fitness($0) < fitness($1) }
    return population.first!
  }
  
  mutating func evolvePopulation(
    crossoverStyle: CrossoverStyle = .uniform,
    mutationProbability: Double = 0.4,
    selectionMethod: SelectionMethod = .random
    ) {
    let count = population.count
    var offspring = crossoveredPopulation(using: crossoverStyle, with: selectionMethod)
    offspring.reserveCapacity(offspring.count + count)
    population.reserveCapacity(offspring.count + count * 2)
    let mutants = mutatedPopulation(withProbability: mutationProbability)
    offspring.append(contentsOf: mutants)
    population.append(contentsOf: offspring)
    population = Array(population.sorted { fitness($0) > fitness($1) }.prefix(upTo: count))
  }
  
  mutating func evolvePopulation(
    crossoverStyle: CrossoverStyle = .uniform,
    mutationProbability: Double = 0.4,
    selectionMethod: SelectionMethod = .random,
    numberOfGenerations k: Int
    ) {
    for _ in 0..<k {
      evolvePopulation(
        crossoverStyle: crossoverStyle,
        mutationProbability: mutationProbability,
        selectionMethod: selectionMethod)
    }
  }
}
