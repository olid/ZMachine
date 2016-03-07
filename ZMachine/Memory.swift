//
//  Memory.swift
//  ZMachine
//

typealias ByteAddress = Int
typealias WordAddress = Int
typealias BitNumber = Int
typealias BitSize = Int

let word_size = 2

let bit1 = 1
let bit2 = 2
let bit3 = 3
let bit4 = 4
let bit5 = 5
let bit6 = 6
let bit7 = 7
let bit8 = 8
let bit9 = 9
let bit10 = 10
let bit11 = 11
let bit12 = 12
let bit13 = 13
let bit14 = 14
let bit15 = 15
let bit16 = 16

let size1 = 1
let size2 = 2
let size3 = 3
let size4 = 4
let size5 = 5
let size6 = 6
let size7 = 7
let size8 = 8
let size9 = 9
let size10 = 10
let size11 = 11
let size12 = 12
let size13 = 13
let size14 = 14
let size15 = 15
let size16 = 16

func fetch_bits(high: BitNumber, length: BitSize, word: Int) -> Int {
    let mask = ~(0xffff << length)
    return (word >> (high - length + 1)) & mask
}

func fetch_bit(high: BitNumber, word: Int) -> Bool {
    return fetch_bits(high, length: 1, word: word) == 1
}

func is_in_range(address: ByteAddress, size: Int) -> Bool {
    return 0 <= address && address < size
}

func is_out_of_range(address: ByteAddress, size: Int) -> Bool {
    return not { is_in_range(address, size: size) }
}

func inc_byte_addr_by(address: ByteAddress, offset: Int) -> ByteAddress {
    return ByteAddress(address + offset)
}

func inc_byte_addr(address: ByteAddress) -> ByteAddress {
    return ByteAddress(address + 1)
}

func dec_byte_addr_by(address: ByteAddress, offset: Int) -> ByteAddress {
    return inc_byte_addr_by(address, offset: 0 - offset)
}

func dereference_string(address: ByteAddress, bytes: CharString) -> Char {
    if is_out_of_range(address, size: CharString.length(bytes)) {
        fatalError("Address out of range")
    } else {
        return bytes[address]
    }
}

func address_of_high_byte(address: WordAddress) -> ByteAddress {
    return ByteAddress(address)
}

func address_of_low_byte(address: WordAddress) -> ByteAddress {
    return ByteAddress(address + 1)
}

func decode_word_address(word_address: WordZStringAddress) -> ZStringAddress {
    return ZStringAddress(word_address * 2)
}

func inc_word_addr_by(address: WordAddress, offset: Int) -> WordAddress {
    return WordAddress(address + offset * word_size)
}

func inc_word_addr(address: WordAddress) -> WordAddress {
    return inc_word_addr_by(address, offset: 1)
}

func first_abbrev_addr(base: AbbreviationTableBase) -> WordAddress {
    return WordAddress(base)
}

func write_byte(story: Story, address: ByteAddress, value: Char) -> Story {
    let dynamic_memory = ImmutableBytes.write_byte(story.dynamic_memory, address: address, value: value)
    return Story(dynamic: dynamic_memory, stat: story.static_memory)
}

func write_word(story: Story, address: ByteAddress, value: Word) -> Story {
    let high = (value >> 8) & 0xff
    let low = value & 0xff
    let story = write_byte(story, address: address_of_high_byte(address), value: high)
    return write_byte(story, address: address_of_low_byte(address), value: low)
}
