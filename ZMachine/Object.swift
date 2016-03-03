//
//  Object.swift
//  ZMachine
//

typealias ObjectBase = Int
typealias PropertyDefaultsTable = Int
typealias ObjectTreeBase = Int
typealias ObjectNumber = Int
typealias ObjectAddress = Int
typealias PropertyHeaderAddress = Int

let default_property_table_entry_size = 2

struct Object {
    static func default_property_table_size(story: Story) -> Int {
        return Story.v3_or_lower(Story.version(story)) ? 31 : 63
    }
    
    static func tree_base(story: Story) -> ObjectTreeBase {
        let base = ObjectBase(Story.object_table_base(story))
        let table_size = default_property_table_size(story)
        return ObjectTreeBase(base + default_property_table_entry_size * table_size)
    }
    
    static func entry_size(story: Story) -> Int {
        return Story.v3_or_lower(Story.version(story)) ? 9 : 14
    }
    
    static func address(story: Story, obj: ObjectNumber) -> ObjectAddress {
        let object_tree_base = ObjectTreeBase(tree_base(story))
        let entry_siz = entry_size(story)
        return ObjectAddress(object_tree_base + (obj - 1) * entry_siz)
    }
    
    static func parent(story: Story, obj: ObjectNumber) -> ObjectNumber {
        let addr = ObjectAddress(address(story, obj: obj))
        if Story.v3_or_lower(Story.version(story)) {
            return ObjectNumber(read_byte(story, address: ByteAddress(addr + 4)))
        } else {
            return ObjectNumber(read_word(story, address: WordAddress(addr + 6)))
        }
    }
    
    static func sibling(story: Story, obj: ObjectNumber) -> ObjectNumber {
        let addr = ObjectAddress(address(story, obj: obj))
        if Story.v3_or_lower(Story.version(story)) {
            return ObjectNumber(read_byte(story, address: ByteAddress(addr + 5)))
        } else {
            return ObjectNumber(read_word(story, address: WordAddress(addr + 8)))
        }
    }
    
    static func child(story: Story, obj: ObjectNumber) -> ObjectNumber {
        let addr = ObjectAddress(address(story, obj: obj))
        if Story.v3_or_lower(Story.version(story)) {
            return ObjectNumber(read_byte(story, address: ByteAddress(addr + 6)))
        } else {
            return ObjectNumber(read_word(story, address: WordAddress(addr + 10)))
        }
    }
    
    static func property_header_address(story: Story, obj: ObjectAddress) -> PropertyHeaderAddress {
        let object_property_offset = Story.v3_or_lower(Story.version(story)) ? 7 : 12
        let addr = ObjectAddress(address(story, obj: obj))
        return PropertyHeaderAddress(read_word(story, address: WordAddress(addr + object_property_offset)))
    }
    
    static func name(story: Story, n: Int) -> String {
        let addr = property_header_address(story, obj: n)
        let length = read_byte(story, address: addr)
        return length == 0 ? "<unnamed>"
            : ZString.read(story, address: ZStringAddress(addr + 1))
    }
    
    static func count(story: Story) -> Int {
        let table_start = tree_base(story)
        let table_end = property_header_address(story, obj: ObjectAddress(1))
        let size = entry_size(story)
        return (table_end - table_start) / size
    }
    
    static func display_object_table(story: Story) -> String {
        let object_count = count(story)
        
        func to_string(i: Int) -> String {
            let current = ObjectAddress(i)
            let parent_obj = parent(story, obj: current)
            let sibling_obj = sibling(story, obj: current)
            let child_obj = child(story, obj: current)
            let obj_name = name(story, n: i)
            return String(format: "%02x: %02x %02x %02x %@\n", arguments: [i, parent_obj, sibling_obj, child_obj, obj_name])
        }
        
        return accumulate_strings_loop(to_string, start: 1, max: object_count + 1)
    }
}



