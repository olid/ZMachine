//
//  ZString.swift
//  ZMachine
//

typealias WordZStringAddress = Int
typealias ZStringAddress = Int

let alphabet_table = [
    [" ", "?", "?", "?", "?", "?", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"],
    [" ", "?", "?", "?", "?", "?", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"],
    [" ", "?", "?", "?", "?", "?", "?", "\n", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", ",", "!", "?", "_", "#", "'", "\"", "/", "\\", "-", ":", "(", ")"]]

enum StringState {
    case Alphabet(Int)
    case Abbrev(AbbreviationNumber)
    case Leading
    case Trailing(Int)
}

let abbrev0 = StringState.Abbrev(AbbreviationNumber(0))
let abbrev32 = StringState.Abbrev(AbbreviationNumber(32))
let abbrev64 = StringState.Abbrev(AbbreviationNumber(64))
let alphabet0 = StringState.Alphabet(0)
let alphabet1 = StringState.Alphabet(1)
let alphabet2 = StringState.Alphabet(2)

struct ZString {
    static func abbreviations_table_base(story: Story) -> AbbreviationTableBase {
        let abbreviations_table_base_offset = WordAddress(24)
        return AbbreviationTableBase(Story.read_word(story)(abbreviations_table_base_offset))
    }
    
    static func abbreviation_zstring(story: Story)(_ n: AbbreviationNumber) -> ZStringAddress {
        if n < 0 || n >= abbreviation_table_length {
            fatalError("Bad offset into abbreviation table (\(n))")
        } else {
            let base = first_abbrev_addr(abbreviations_table_base(story))
            let abbr_addr = inc_word_addr_by(base)(n)
            let word_addr = WordZStringAddress(Story.read_word(story)(abbr_addr))
            return decode_word_address(word_addr)
        }
    }
    
    static func read(story: Story)(_ address: ZStringAddress) -> String {
        func process_zchar(zchar: ZChar, state: StringState) -> (String, StringState) {
            switch (zchar, state) {
                case (1, .Alphabet): return ("", abbrev0)
                case (2, .Alphabet): return ("", abbrev32)
                case (3, .Alphabet): return ("", abbrev64)
                case (4, .Alphabet): return ("", alphabet1)
                case (5, .Alphabet): return ("", alphabet2)
                case (6, .Alphabet(2)): return ("", .Leading)
                case (_, .Alphabet(let a)): return (alphabet_table[a][zchar], alphabet0)
                case (_, .Abbrev(let a)):
                    let abbrv = AbbreviationNumber(a + zchar)
                    let addr = abbreviation_zstring(story)(abbrv)
                    let str = read(story)(addr)
                    return (str, alphabet0)
                case (_, .Leading): return ("", (.Trailing(zchar)))
                case (_, .Trailing(let high)):
                    let s = string_of_char(high * 32 + zchar)
                    return (s, alphabet0)
            }
        }
        
        func aux(acc: String)(_ state1: StringState)(_ current_address: ZStringAddress) -> String {
            let zchar_bit_size = size5
            let word = Story.read_word(story)(current_address)
            let is_end = fetch_bit(bit15)(word)
            let zchar1 = ZChar(fetch_bits(bit14)(zchar_bit_size)(word))
            let zchar2 = ZChar(fetch_bits(bit9)(zchar_bit_size)(word))
            let zchar3 = ZChar(fetch_bits(bit4)(zchar_bit_size)(word))
            let (text1, state2) = process_zchar(zchar1, state: state1)
            let (text2, state3) = process_zchar(zchar2, state: state2)
            let (text3, state_next) = process_zchar(zchar3, state: state3)
            let new_acc = acc + text1 + text2 + text3
            
            if is_end {
                return new_acc
            } else {
                return aux(new_acc)(state_next)((inc_word_addr(current_address)))
            }
        }
        
        return aux("")(alphabet0)(WordAddress(address))
    }
    
    static func display_bytes(story: Story)(_ addr: ZStringAddress) -> CharString {
        func aux(current: WordAddress)(_ acc: String) -> String {
            let word = Story.read_word(story)(current)
            let is_end = fetch_bits(bit15)(size1)(word)
            let zchar1 = fetch_bits(bit14)(size5)(word)
            let zchar2 = fetch_bits(bit9)(size5)(word)
            let zchar3 = fetch_bits(bit4)(size5)(word)
            let s = acc + alphabet_table[0][zchar1] + alphabet_table[0][zchar2] + alphabet_table[0][zchar3]
            if is_end == 1 {
                return s
            }
            
            return aux(inc_word_addr(current))(s)
        }
        return aux(WordAddress(addr))("").charString
    }
}












