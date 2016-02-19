//
//  ImmutableBytes.swift
//  ZMachine
//

struct ImmutableBytes {
    let original_bytes: CharString
    let edits: Map<Int, Char>
    
    init(bytes: CharString) {
        self.original_bytes = bytes
        self.edits = Map<Int, Char>()
    }
    
    init(bytes: CharString, edits: Map<Int, Char>) {
        self.original_bytes = bytes
        self.edits = edits
    }
    
    static func size(bytes: ImmutableBytes) -> Int {
        return bytes.original_bytes.count
    }
    
    static func read_byte(bytes: ImmutableBytes, address: ByteAddress) -> Char {
        if is_out_of_range(address, size: size(bytes)) {
            fatalError("Address is out of range")
        } else {
            if bytes.edits.mem(address) {
                return bytes.edits.find(address)
            } else {
                return bytes.original_bytes[address]
            }
        }
    }
    
    static func write_byte(bytes: ImmutableBytes, address: ByteAddress, value: Char) -> ImmutableBytes {
        if is_out_of_range(address, size: size(bytes)) {
            fatalError("Address is out of range")
        } else {
            let addr = Int(address)
            return ImmutableBytes(bytes: bytes.original_bytes, edits: bytes.edits.add(addr, value: value))
        }
    }
}





