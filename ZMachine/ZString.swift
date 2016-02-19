//
//  ZString.swift
//  ZMachine
//

typealias WordZStringAddress = Int
typealias ZStringAddress = Int

let alphabet_table = [" ", "^", "^", "*", "*", "?", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

struct ZString {
    static func abbreviations_table_base(story: Story) -> AbbreviationTableBase {
        let abbreviations_table_base_offset = WordAddress(24)
        return AbbreviationTableBase(read_word(story, address: abbreviations_table_base_offset))
    }
    
    static func abbreviation_zstring(story: Story, n: AbbreviationNumber) -> ZStringAddress {
        if n < 0 || n >= abbreviation_table_length {
            fatalError("Bad offset into abbreviation table (\(n))")
        } else {
            let base = first_abbrev_addr(abbreviations_table_base(story))
            let abbr_addr = inc_word_addr_by(base, offset: n)
            let word_addr = WordZStringAddress(read_word(story, address: abbr_addr))
            return decode_word_address(word_addr)
        }
    }
    
    static func display_bytes(story: Story, addr: ZStringAddress) -> CharString {
        func aux(current: WordAddress, acc: String) -> String {
            let word = read_word(story, address: current)
            let is_end = fetch_bits(bit15, length: size1, word: word)
            let zchar1 = fetch_bits(bit14, length: size5, word: word)
            let zchar2 = fetch_bits(bit9, length: size5, word: word)
            let zchar3 = fetch_bits(bit4, length: size5, word: word)
            let s = acc + alphabet_table[zchar1] + alphabet_table[zchar2] + alphabet_table[zchar3]
            if is_end == 1 {
                return s
            }
            
            return aux(inc_word_addr(current), acc: s)
        }
        return aux(WordAddress(addr), acc: "").charString
    }
}
