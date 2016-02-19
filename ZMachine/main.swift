//
//  main.swift
//  ZMachine
//

let story = Story.load("zcode/minizork.z3")

for x in 0...95 {
    let zstring = ZString.abbreviation_zstring(story, n: AbbreviationNumber(x))
    let text = ZString.display_bytes(story, addr: zstring)
    print(charstring_to_string(text))
}

