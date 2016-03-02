//
//  main.swift
//  ZMachine
//

let story = Story.load("zcode/minizork.z3")
let dict = Dictionary.display(story)
print(Story.version(story))
print(Story.v3_or_lower(Story.version(story)))
print(dict)

