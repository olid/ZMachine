//
//  Story.swift
//  ZMachine
//

let header_size = 64
let static_memory_base_offset = WordAddress(14)
let abbreviation_table_length = 96

typealias AbbreviationNumber = Int
typealias AbbreviationTableBase = Int

struct Story {
    let dynamic_memory: ImmutableBytes
    let static_memory: CharString
    
    init(dynamic: CharString, stat: CharString) {
        dynamic_memory = ImmutableBytes(bytes: dynamic)
        static_memory = stat
    }
    
    init(dynamic: ImmutableBytes, stat: CharString) {
        dynamic_memory = dynamic
        static_memory = stat
    }

    static func load(filename: String) -> Story {
        let file = get_file(filename)
        let len = CharString.length(file)
        if len < header_size {
            fatalError("\(filename) is not a valid story file (its way too short!)")
        } else {
            let high = dereference_string(address_of_high_byte(static_memory_base_offset), bytes: file)
            let low = dereference_string(address_of_low_byte(static_memory_base_offset), bytes: file)
            let dynamic_length = high * 256 + low
            if dynamic_length > len {
                fatalError("\(filename) is not a valid story file (its too short!)")
            } else {
                let dynamic = CharString.sub(file, start: 0, length: dynamic_length)
                let stat = CharString.sub(file, start: dynamic_length, length: (len - dynamic_length))
                return Story(dynamic: dynamic, stat: stat)
            }
        }
    }
    
    static func dictionary_base(story: Story) -> DictionaryBase {
        let dictionary_base_offset = WordAddress(8)
        return DictionaryBase(read_word(story, address: dictionary_base_offset))
    }
}








