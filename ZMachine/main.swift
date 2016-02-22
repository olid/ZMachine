//
//  main.swift
//  ZMachine
//

let story = Story.load("zcode/minizork.z3")
let zstring = ZStringAddress(0xb106)
let text = ZString.read(story, address: zstring)
print(text)

