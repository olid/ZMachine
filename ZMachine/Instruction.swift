//
//  Interpreter.swift
//  ZMachine
//

enum OpcodeForm {
    case LongForm
    case ShortForm
    case VariableForm
    case ExtendedForm
}

enum OperandCount {
    case OP0
    case OP1
    case OP2
    case VAR
}

enum OperandType {
    case LargeOperand
    case SmallOperand
    case VariableOperand
    case Omitted
}

typealias LocalVariable = Int
typealias GlobalVariable = Int
typealias InstructionAddress = Int

enum VariableLocation {
    case Stack
    case Local(LocalVariable)
    case Global(GlobalVariable)
}

enum Operand {
    case Large(Int)
    case Small(Int)
    case Variable(VariableLocation)
}

enum BranchAddress {
    case ReturnTrue
    case ReturnFalse
    case BranchAddress(InstructionAddress)
}


let one_operand_bytecodes: [ByteCode] = [
    .OP1_128, .OP1_129, .OP1_130, .OP1_131, .OP1_132, .OP1_133, .OP1_134, .OP1_135,
    .OP1_136, .OP1_137, .OP1_138, .OP1_139, .OP1_140, .OP1_141, .OP1_142, .OP1_143]

let zero_operand_bytecodes: [ByteCode] = [
    .OP0_176, .OP0_177, .OP0_178, .OP0_179, .OP0_180, .OP0_181, .OP0_182, .OP0_183,
    .OP0_184, .OP0_185, .OP0_186, .OP0_187, .OP0_188, .OP0_189, .OP0_190, .OP0_191]

let two_operand_bytecodes: [ByteCode] = [
    .ILLEGAL, .OP2_1, . OP2_2, . OP2_3, . OP2_4, . OP2_5, .  OP2_6, .  OP2_7,
    .OP2_8, .  OP2_9, . OP2_10, .OP2_11, .OP2_12, .OP2_13, . OP2_14, . OP2_15,
    .OP2_16, . OP2_17, .OP2_18, .OP2_19, .OP2_20, .OP2_21, . OP2_22, . OP2_23,
    .OP2_24, . OP2_25, .OP2_26, .OP2_27, .OP2_28, .ILLEGAL, .ILLEGAL, .ILLEGAL]

let var_operand_bytecodes: [ByteCode] = [
    .VAR_224, .VAR_225, .VAR_226, .VAR_227, .VAR_228, .VAR_229, .VAR_230, .VAR_231,
    .VAR_232, .VAR_233, .VAR_234, .VAR_235, .VAR_236, .VAR_237, .VAR_238, .VAR_239,
    .VAR_240, .VAR_241, .VAR_242, .VAR_243, .VAR_244, .VAR_245, .VAR_246, .VAR_247,
    .VAR_248, .VAR_249, .VAR_250, .VAR_251, .VAR_252, .VAR_253, .VAR_254, .VAR_255]

let ext_bytecodes: [ByteCode] = [
    .EXT_0, .EXT_1, .EXT_2, .EXT_3, .EXT_4, .EXT_5, .EXT_6, .EXT_7,
    .EXT_8, .EXT_9, .EXT_10, .EXT_11, .EXT_12, .EXT_13, .EXT_14, .ILLEGAL,
    .EXT_16, .EXT_17, .EXT_18, .EXT_19, .EXT_20, .EXT_21, .EXT_22, .EXT_23,
    .EXT_24, .EXT_25, .EXT_26, .EXT_27, .EXT_28, .EXT_29, .ILLEGAL, .ILLEGAL]

struct Instruction {
    func decode(story: Story, address: InstructionAddress) -> () {
        let addr = ByteAddress(address)
        let ver = Story.version(story)
        let read_word = Story.read_word(story)
        let read_byte = Story.read_byte(story)
        let read_zstring = ZString.read(story)
        let zstring_length = ZString.length(story)
        
        func decode_form(address: InstructionAddress) -> OpcodeForm {
            let byte = read_byte(address)
            switch fetch_bits(bit7)(size2)(byte) {
                case 3: return .VariableForm
                case 2: return byte == 190 ? .ExtendedForm : .ShortForm
                default: return .LongForm
            }
        }
        
        func decode_op_count(address: InstructionAddress)(form: OpcodeForm) -> OperandCount {
            let byte = read_byte(address)
            switch form {
                case .ShortForm: return fetch_bits(bit5)(size2)(byte) == 3 ? .OP0 : .OP1
                case .LongForm: return .OP2
                case .VariableForm: return fetch_bit(bit5)(byte) ? .VAR : .OP2
                case .ExtendedForm: return .VAR
            }
        }
        
        func decode_opcode(address: InstructionAddress)(form: OpcodeForm)(op_count: OperandCount) -> ByteCode {
            let byte = read_byte(address)
            switch (form, op_count) {
                case (.ExtendedForm, _):
                    let maximum_extended = 29
                    let ext = read_byte(inc_byte_addr(address))
                    return ext > maximum_extended ? .ILLEGAL : ext_bytecodes[ext]
                case (_, .OP0): return zero_operand_bytecodes[fetch_bits(bit3)(size4)(byte)]
                case (_, .OP1): return one_operand_bytecodes[fetch_bits(bit3)(size4)(byte)]
                case (_, .OP2): return two_operand_bytecodes[fetch_bits(bit4)(size5)(byte)]
                case (_, .VAR): return var_operand_bytecodes[fetch_bits(bit4)(size5)(byte)]
            }
        }
        
        func get_opcode_length(form: OpcodeForm) -> Int {
            switch form {
                case .ExtendedForm: return 2
                default: return 1
            }
        }
        
        func decode_types(n: Int) -> OperandType {
            switch n {
                case 0: return .LargeOperand
                case 1: return .SmallOperand
                case 2: return .VariableOperand
                default: return .Omitted
            }
        }
        
        func decode_variable_types(type_byte: Word) -> [OperandType] {
            func aux(i: Int, acc: [OperandType]) -> [OperandType] {
                if i > 3 {
                    return acc
                } else {
                    let type_bits = fetch_bits(BitNumber(i * 2 + 1))(size2)(type_byte)
                    switch decode_types(type_bits) {
                        case .Omitted: return aux(i + 1, acc: acc)
                        case let x: return aux(i + 1, acc: x |< acc)
                    }
                }
            }
            return aux(0, acc: [])
        }
        
        func decode_operand_types(address: InstructionAddress)(_ form: OpcodeForm)(_ op_count: OperandCount)(_ opcode: ByteCode) -> [OperandType] {
            switch(form, op_count, opcode) {
                case (_, .OP0, _): return []
                case (_, .OP1, _):
                    let b = read_byte(address)
                    return [decode_types(fetch_bits(bit5)(size2)(b))]
                case (.LongForm, _, _):
                    let b = read_byte(address)
                    switch(fetch_bits(bit6)(size2)(b)) {
                        case 0: return [.SmallOperand, .SmallOperand]
                        case 1: return [.SmallOperand, .VariableOperand]
                        case 2: return [.VariableOperand, .SmallOperand]
                        case _: return [.VariableOperand, .VariableOperand]
                    }
                case (.VariableForm, _, .VAR_236),
                     (.VariableForm, _, .VAR_250):
                    let opcode_length = get_opcode_length(form)
                    let type_byte_0 = read_byte(inc_byte_addr_by(address)(opcode_length))
                    let type_byte_1 = read_byte(inc_byte_addr_by(address)(opcode_length + 1))
                    return decode_variable_types(type_byte_0) >< decode_variable_types(type_byte_1)
                case _:
                    let opcode_length = get_opcode_length(form)
                    let type_byte = read_byte(inc_byte_addr_by(address)(opcode_length))
                    return decode_variable_types(type_byte)
            }
        }
        
        func get_type_length(form: OpcodeForm)(_ opcode: ByteCode) -> Int {
            switch (form, opcode) {
                case (.VariableForm, .VAR_236),
                     (.VariableForm, .VAR_250): return 2
                case (.VariableForm, _): return 1
                default: return 0
            }
        }
        
        func decode_variable(n: Int) -> VariableLocation {
            let maximum_local = 15
            switch n {
                case 0: return .Stack
                case 1...maximum_local: return .Local(n)
                default: return .Global(n)
            }
        }
        
        func decode_operands(operand_address: InstructionAddress)(_ operand_types: [OperandType]) -> [Operand] {
            switch operand_types.headtail {
                case (.None, _): return []
                case (let head, let remaining_types) where head == .LargeOperand:
                    let w = read_word(operand_address)
                    let tail = decode_operands(inc_byte_addr_by(operand_address)(word_size))(remaining_types)
                    return .Large(w) |< tail
                case (let head, let remaining_types) where head == .SmallOperand:
                    let b = read_byte(operand_address)
                    let tail = decode_operands(inc_byte_addr(operand_address))(remaining_types)
                    return .Small(b) |< tail
                case (let head, let remaining_types) where head == .VariableOperand:
                    let b = read_byte(operand_address)
                    let v = decode_variable(b)
                    let tail = decode_operands(inc_byte_addr(operand_address))(remaining_types)
                    return .Variable(v) |< tail
                case (let head, _) where head == .Omitted:
                    fatalError("Ommitted operand type passed to decode_operands")
                default:
                    fatalError("Something broke (types = \(operand_types.headtail))")
            }
        }
        
        func get_operand_length(operand_types: [OperandType]) -> Int {
            switch operand_types.headtail {
                case (.None, _): return 0
                case (let head, let remaining_types) where head == .LargeOperand: return word_size + get_operand_length(remaining_types)
                case (_, let remaining_types): return 1 + get_operand_length(remaining_types)
            }
        }
        
        func has_store(opcode: ByteCode)(_ ver: Version) -> Bool {
            switch opcode {
                case .OP1_143: return Story.v4_or_lower(ver)
                case .OP0_181: return Story.v4_or_higher(ver)
                case .OP0_182: return Story.v4_or_higher(ver)
                case .OP0_185: return Story.v4_or_higher(ver)
                case .VAR_233: return ver == .V6
                case .VAR_228: return Story.v5_or_higher(ver)
                case .OP2_8, .OP2_9, .OP2_15, .OP2_16, .OP2_17, .OP2_18  , .OP2_19,
                    .OP2_20, .OP2_21, .OP2_22 , .OP2_23, .OP2_24, .OP2_25,
                    .OP1_129, .OP1_130, .OP1_131, .OP1_132, .OP1_136, .OP1_142,
                    .VAR_224, .VAR_231, .VAR_236, .VAR_246, .VAR_247, .VAR_248,
                    .EXT_0, .EXT_1, .EXT_2, .EXT_3, .EXT_4, .EXT_9,
                    .EXT_10, .EXT_19, .EXT_29: return true
                default: return false
            }
        }
        
        func decode_store(store_address: ByteAddress)(_ opcode: ByteCode)(_ ver: Version) -> VariableLocation? {
            if has_store(opcode)(ver) {
                let store_byte = read_byte(store_address)
                return .Some(decode_variable(store_byte))
            } else {
                return .None
            }
        }
        
        func get_store_length(opcode: ByteCode)(_ ver: Version) -> Int {
            return has_store(opcode)(ver) ? 1 : 0
        }
        
        func has_branch(opcode: ByteCode)(_ ver: Version) -> Bool {
            switch opcode {
                case .OP0_181: return Story.v3_or_lower(ver)
                case .OP0_182: return Story.v3_or_lower(ver)
                case .OP2_1, .OP2_2, .OP2_3, .OP2_4, .OP2_5, .OP2_6, .OP2_7, .OP2_10,
                    .OP1_128, .OP1_129, .OP1_130, .OP0_189, .OP0_191,
                    .VAR_247, .VAR_255,
                    .EXT_6, .EXT_14, .EXT_24, .EXT_27: return true
                default: return false
            }
        }
        
        func decode_branch(branch_code_address: InstructionAddress)(_ opcode: ByteCode)(_ ver: Version) -> (Bool, BranchAddress)? {
            if has_branch(opcode)(ver) {
                let high = read_byte(branch_code_address)
                let sense = fetch_bit(bit7)(high)
                let bottom6 = fetch_bits(bit5)(size6)(high)
                let offset = when { fetch_bit(bit6)(high) }.then {
                    bottom6
                }.otherwise {
                    let low = read_byte(inc_byte_addr(branch_code_address))
                    let unsigned = 256 * bottom6 + low
                    return unsigned < 8192 ? unsigned : unsigned - 16384
                }
                let branch: (Bool, BranchAddress) = {
                    switch offset {
                        case 0: return (sense, BranchAddress.ReturnTrue)
                        case 1: return (sense, BranchAddress.ReturnFalse)
                        default:
                            let branch_length = fetch_bit(bit6)(high) ? 1 : 2
                            let address_after = inc_byte_addr_by(branch_length)(branch_length)
                            let branch_target = InstructionAddress(address_after + offset - 2)
                            return (sense, BranchAddress.BranchAddress(branch_target))
                    }
                }()
                return .Some(branch)
            } else {
                return .None
            }
        }
        
        func get_branch_length(branch_code_address: InstructionAddress)(_ opcode: ByteCode)(_ ver: Version) -> Int {
            if has_branch(opcode)(ver) {
                let b = read_byte(branch_code_address)
                return fetch_bit(bit6)(b) ? 1 : 2
            } else {
                return 0
            }
        }
    }
}






