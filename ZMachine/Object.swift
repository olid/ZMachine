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
let invalid_object = ObjectNumber(0)

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
    
    static func address(story: Story, _ obj: ObjectNumber) -> ObjectAddress {
        let object_tree_base = ObjectTreeBase(tree_base(story))
        let entry_siz = entry_size(story)
        return ObjectAddress(object_tree_base + (obj - 1) * entry_siz)
    }
    
    static func parent(story: Story, _ obj: ObjectNumber) -> ObjectNumber {
        let addr = ObjectAddress(address(story, obj))
        if Story.v3_or_lower(Story.version(story)) {
            return ObjectNumber(Story.read_byte(story, ByteAddress(addr + 4)))
        } else {
            return ObjectNumber(Story.read_word(story, WordAddress(addr + 6)))
        }
    }
    
    static func sibling(story: Story, _ obj: ObjectNumber) -> ObjectNumber {
        let addr = ObjectAddress(address(story, obj))
        if Story.v3_or_lower(Story.version(story)) {
            return ObjectNumber(Story.read_byte(story, ByteAddress(addr + 5)))
        } else {
            return ObjectNumber(Story.read_word(story, WordAddress(addr + 8)))
        }
    }
    
    static func child(story: Story, _ obj: ObjectNumber) -> ObjectNumber {
        let addr = ObjectAddress(address(story, obj))
        if Story.v3_or_lower(Story.version(story)) {
            return ObjectNumber(Story.read_byte(story, ByteAddress(addr + 6)))
        } else {
            return ObjectNumber(Story.read_word(story, WordAddress(addr + 10)))
        }
    }
    
    static func property_header_address(story: Story, _ obj: ObjectAddress) -> PropertyHeaderAddress {
        let object_property_offset = Story.v3_or_lower(Story.version(story)) ? 7 : 12
        let addr = ObjectAddress(address(story, obj))
        return PropertyHeaderAddress(Story.read_word(story, WordAddress(addr + object_property_offset)))
    }
    
    static func name(story: Story, _ n: Int) -> String {
        let addr = property_header_address(story, n)
        let length = Story.read_byte(story, addr)
        return length == 0 ? "<unnamed>"
            : ZString.read(story, ZStringAddress(addr + 1))
    }
    
    static func count(story: Story) -> Int {
        let table_start = tree_base(story)
        let table_end = property_header_address(story, ObjectAddress(1))
        let size = entry_size(story)
        return (table_end - table_start) / size
    }
    
    static func display_object_table(story: Story) -> String {
        let object_count = count(story)
        
        func to_string(i: Int) -> String {
            let current = ObjectAddress(i)
            let parent_obj = parent(story, current)
            let sibling_obj = sibling(story, current)
            let child_obj = child(story, current)
            let obj_name = name(story, i)
            return String(format: "%02x: %02x %02x %02x %@\n", arguments: [i, parent_obj, sibling_obj, child_obj, obj_name])
        }
        
        return accumulate_strings_loop(to_string, 1, object_count + 1)
    }
    
    static func roots(story: Story) -> [ObjectNumber] {
        func aux(obj: ObjectNumber, acc: [ObjectNumber]) -> [ObjectNumber] {
            let current = obj
            if current == invalid_object {
                return acc
            } else if parent(story, current) == invalid_object {
                return aux(obj - 1, acc: current |< acc)
            } else {
                return aux(obj - 1, acc:  acc)
            }
        }
        
        return aux(count(story), acc: [])
    }
    
    static func display_object_tree(story: Story) -> String {
        func aux(acc: String, indent: String, obj: ObjectNumber) -> String {
            if obj == invalid_object {
                return acc
            } else {
                let obj_name = name(story, obj)
                let child_obj = child(story, obj)
                let sibling_obj = sibling(story, obj)
                let object_text = String(format: "%@%@\n", arguments: [indent, obj_name])
                let with_object = acc + object_text
                let new_indent = "|   " + indent
                let with_children = aux(with_object, indent: new_indent, obj: child_obj)
                return aux(with_children, indent: indent, obj: sibling_obj)
            }
        }
        
        func to_string(obj: ObjectNumber) -> String {
            return aux("", indent: "", obj: obj)
        }
        
        return accumulate_strings(to_string, roots(story))
    }
}









