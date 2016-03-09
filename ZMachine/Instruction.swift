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

typealias InstructionAddress = Int

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
    }
}





