//
//  Story.swift
//  ZMachine
//

let header_size = 64
let static_memory_base_offset = WordAddress(14)
let abbreviation_table_length = 96
let version_offset = ByteAddress(0)

typealias AbbreviationNumber = Int
typealias AbbreviationTableBase = Int

enum Version {
    case V1
    case V2
    case V3
    case V4
    case V5
    case V6
    case V7
    case V8
}

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
    
    static func version(story: Story) -> Version {
        switch read_byte(story, address: version_offset) {
            case 1: return .V1
            case 2: return .V2
            case 3: return .V3
            case 4: return .V4
            case 5: return .V5
            case 6: return .V6
            case 7: return .V7
            case 8: return .V8
            default: fatalError("Unknown version")
        }
    }
    
    static func v3_or_lower(v: Version) -> Bool {
        switch v {
            case .V1, .V2, .V3: return true
            case .V4, .V5, .V6, .V7, .V8: return false
        }
    }
}








