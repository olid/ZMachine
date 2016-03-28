//
//  main.swift
//  ZMachine
//

import Darwin

@noreturn func die(msg : String) {
  print(msg)
  exit(0)
}

var args = Process.arguments
guard args.count > 1 else { die("Usage:  ZMachine path ...") }

args.removeAtIndex(0)
for arg in args {
  let story = Story.load(arg)
  let dict = Dictionary.display(story)
  print("Version: \(Story.version(story))")
  print("Dictionary: " + dict)

  let tree = Object.display_object_tree(story)
  print(tree)
}

//let pissman = when{10 > 6}.then{ "PIS" }.otherwise{ "NO PISS" }
//print(pissman)
