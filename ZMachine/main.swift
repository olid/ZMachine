//
//  main.swift
//  ZMachine
//

let story = Story.load("zcode/minizork.z3")
let dict = Dictionary.display(story)
print("Version: \(Story.version(story))")
print("Dictionary: " + dict)

let table = Object.display_object_table(story)
print("Object table: " + table)
