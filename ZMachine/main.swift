//
//  main.swift
//  ZMachine
//

let story = Story.load("zcode/minizork.z3")
let dict = Dictionary.display(story)
print("Version: \(Story.version(story))")
print("Dictionary: " + dict)

let tree = Object.display_object_tree(story)
print(tree)
