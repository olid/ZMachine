//
//  Utility.swift
//  ZMachine
//

func string_of_char(char: ZChar) -> String {
    return String(UnicodeScalar(char))
}

func charstring_to_string(char_string: CharString) -> String {
    return char_string.reduce("") {
        $0 + string_of_char($1)
    }
}

func accumulate_strings_loop(to_string: Int -> String, _ start: Int, _ max: Int) -> String {
    func aux(acc: String, _ i: Int) -> String {
        if i >= max {
            return acc
        } else {
            return aux(acc + to_string(i), i + 1)
        }
    }
    
    return aux("", start)
}

func accumulate_strings<T>(to_string: T -> String, _ items: [T]) -> String {
    func folder(text: String, item: T) -> String {
        return text + to_string(item)
    }
    return Array<T>.fold_left(items, acc: "", map: folder)
}

