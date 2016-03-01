//
//  Dictionary.swift
//  ZMachine
//

typealias DictionaryBase = Int
typealias DictionaryTableBase = Int
typealias DictionaryAddress = Int
typealias DictionaryNumber = Int

struct Dictionary {
    static func word_seperators_base(base: DictionaryBase) -> ByteAddress {
        return ByteAddress(base)
    }
    
    static func word_seperators_count(story: Story) -> Int {
        let dict_base = Story.dictionary_base(story)
        let ws_base = word_seperators_base(dict_base)
        return read_byte(story, address: ws_base)
    }
    
    static func entry_base(story: Story) -> ByteAddress {
        let dict_base = Story.dictionary_base(story)
        let ws_count = word_seperators_count(story)
        let ws_base = word_seperators_base(dict_base)
        return inc_byte_addr_by(ws_base, offset: ws_count + 1)
    }
    
    static func entry_length(story: Story) -> Int {
        return read_byte(story, address: entry_base(story))
    }
    
    static func entry_count(story: Story) -> Int {
        let addr = ByteAddress(inc_byte_addr(entry_base(story)))
        return read_word(story, address: WordAddress(addr))
    }
    
    static func table_base(story: Story) -> DictionaryTableBase {
        let addr = ByteAddress(inc_byte_addr_by(entry_base(story), offset: 3))
        return DictionaryTableBase(addr)
    }
    
    static func entry_address(story: Story, dictionary_number: DictionaryNumber) -> DictionaryAddress {
        let base = DictionaryTableBase(table_base(story))
        let length = entry_length(story)
        return DictionaryAddress(base + dictionary_number * length)
    }
    
    static func entry(story: Story, dictionary_number: DictionaryNumber) -> String {
        let addr = DictionaryAddress(entry_address(story, dictionary_number: dictionary_number))
        return ZString.read(story, address: ZStringAddress(addr))
    }
    
    static func display(story: Story) -> String {
        let count = entry_count(story)
        
        func to_string(i: Int) -> String {
            return entry(story, dictionary_number: DictionaryNumber(i)) + " "
        }
        
        return accumulate_strings_loop(to_string, start: 0, max: count)
    }
}