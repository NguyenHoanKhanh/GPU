import os
import re

# Register map for r0 to r31
register_map = {f"r{i}": i for i in range(32)}

# Bank mapping
bank_map = {
    "param0": "000",  # Read-only
    # "param1": "001",  # Read-only
    # "param2": "010",  # Read-only
    # "param3": "011",  # Read-only
    "temp0": "001",   # Read-write
    # "temp1": "101",   # Read-write
    # "temp2": "110",   # Read-write
    # "temp3": "111"    # Read-write
}

# Instruction map (sửa type của class thành R2)
instruction_map = {
    "nop": {"opcode": "00000000", "funct": "00000", "type": "R0"},
    "class": {"opcode": "00000000", "funct": "00001", "type": "R2"},  # Sửa thành R2
    "add": {"opcode": "00000001", "funct": "00000", "type": "R3"},
    "sub": {"opcode": "00000001", "funct": "00001", "type": "R3"},
    "mul": {"opcode": "00000001", "funct": "00010", "type": "R3"},
    "sgnj": {"opcode": "00000001", "funct": "00011", "type": "R3"},
    "sgjn": {"opcode": "00000001", "funct": "00100", "type": "R3"},
    "sgjx": {"opcode": "00000001", "funct": "00101", "type": "R3"},
    "min": {"opcode": "00000001", "funct": "00110", "type": "R3"},
    "max": {"opcode": "00000001", "funct": "00111", "type": "R3"},
    "seq": {"opcode": "00000001", "funct": "01000", "type": "R3"},
    "slt": {"opcode": "00000001", "funct": "01001", "type": "R3"},
    "sle": {"opcode": "00000001", "funct": "01010", "type": "R3"},
    "madd": {"opcode": "00000010", "funct": "00000", "type": "R4"},
    "msub": {"opcode": "00000010", "funct": "00001", "type": "R4"},
    "nmadd": {"opcode": "00000010", "funct": "00010", "type": "R4"},
    "nmsub": {"opcode": "00000010", "funct": "00011", "type": "R4"},
    "cvt_f2i": {"opcode": "00000100", "funct": "00000", "type": "R2"},
    "cvtu_f2i": {"opcode": "00000100", "funct": "00001", "type": "R2"},
    "cvt_i2f": {"opcode": "00000100", "funct": "00010", "type": "R2"},
    "cvtu_i2f": {"opcode": "00000100", "funct": "00011", "type": "R2"},
    "addi": {"opcode": "00001000", "funct": "00000", "type": "I"},
    "subi": {"opcode": "00001000", "funct": "00001", "type": "I"},
    "muli": {"opcode": "00001000", "funct": "00010", "type": "I"},
    "mini": {"opcode": "00001000", "funct": "00110", "type": "I"},
    "maxi": {"opcode": "00001000", "funct": "00111", "type": "I"},
    "seqi": {"opcode": "00001000", "funct": "01000", "type": "I"},
    "slti": {"opcode": "00001000", "funct": "01001", "type": "I"},
    "slei": {"opcode": "00001000", "funct": "01010", "type": "I"},
}

# Swizzle mapping
swizzle_map = {"x": "00", "y": "01", "z": "10", "w": "11"}

# Rounding mode mapping
rounding_mode_map = {
    "rne": "000",
    "rtz": "001",
    "rdn": "010",
    "rup": "011",
}

def to_bin(val, bits):
    if val < 0:
        val = (1 << bits) + val
    return format(val, f"0{bits}b")

def to_hex(binstr):
    hex_val = f"{int(binstr, 2):032x}"
    return hex_val

def parse_swizzle(swizzle_str):
    if not swizzle_str.startswith("."):
        return "00000000"
    swizzle = swizzle_str[1:]
    if len(swizzle) != 4 or not all(c in swizzle_map for c in swizzle):
        raise ValueError(f"Invalid swizzle pattern: {swizzle}")
    return "".join(swizzle_map[c] for c in swizzle)

def parse_mask(mask_str):
    if not mask_str.startswith("."):
        return "1111"
    mask = mask_str[1:]
    if not mask or len(mask) > 4 or not all(c in swizzle_map for c in mask):
        raise ValueError(f"Invalid mask pattern: {mask}")
    result = ["0"] * 4
    for c in mask:
        if c == "x":
            result[0] = "1"
        elif c == "y":
            result[1] = "1"
        elif c == "z":
            result[2] = "1"
        elif c == "w":
            result[3] = "1"
    return "".join(result)

def encode_instruction(instr, current_idx, label_map):
    tokens = re.split(r"[\s,]+", instr.strip())
    tokens = [t for t in tokens if t]
    mnemonic = tokens[0].lower()
    saturatedres = "0"
    
    # Đặc biệt: Lệnh nop trả về 128 bit toàn 0
    if mnemonic == "nop":
        machine_code = "0" * 128
        return to_hex(machine_code)

    # Xử lý hậu tố _sat
    if "_sat" in mnemonic:
        mnemonic = mnemonic.replace("_sat", "")
        saturatedres = "1"
        tokens[0] = mnemonic

    if mnemonic not in instruction_map:
        raise ValueError(f"Unknown instruction: {mnemonic}")
    spec = instruction_map[mnemonic]

    opcode = spec["opcode"]
    funct = spec["funct"]
    rm = "000"
    endflag = "0"
    waitpoint = "0"
    predicated = "0"
    invertpred = "0"
    predreg = "00000"
    op1bank = "100"
    op1negate = "0"
    op1absolute = "0"
    op2bank = "100"
    op2negate = "0"
    op2absolute = "0"
    op3bank = "100"
    op3negate = "0"
    op3absolute = "0"
    resbank = "100"
    mask = "1111"
    reserved = "00000000000000"  # 14 bits
    op1reg = "00000000"
    op1swizzle = "00000000"
    resreg = "00000000"
    op2reg = "00000000"
    op2swizzle = "00000000"
    op3reg = "00000000"
    op3swizzle = "00000000"
    reserved_q1 = "00000000"
    immediate = "0" * 32

    if ".rm=" in instr:
        rm_part = instr.split(".rm=")[1].split()[0]
        if rm_part not in rounding_mode_map:
            raise ValueError(f"Invalid rounding mode: {rm_part}")
        rm = rounding_mode_map[rm_part]
        tokens = re.split(r"[\s,]+", instr.split(".rm=")[0].strip())
        tokens = [t for t in tokens if t]

    def parse_register(token, is_destination=False):
        bank = "temp0"
        swizzle = ""
        mask = ""
        negate = "0"
        absolute = "0"
        reg = token

        if token.startswith("-"):
            negate = "1"
            reg = reg[1:]
        if reg.startswith("|"):
            absolute = "1"
            reg = reg[1:]

        parts = reg.split("@")
        reg = parts[0]
        if len(parts) > 1:
            bank_part = parts[1].lower()
            bank_swizzle = bank_part.split(".")
            bank = bank_swizzle[0]
            if bank not in bank_map:
                raise ValueError(f"Invalid bank: {bank}")
            if is_destination and bank_map[bank] in ["000"]:
                raise ValueError(f"Cannot write to read-only bank: {bank}")
            if len(bank_swizzle) > 1:
                if is_destination:
                    mask = "." + bank_swizzle[1]
                else:
                    swizzle = "." + (bank_swizzle[1])[::-1]
            else:
                if is_destination:
                    mask = ".xyzw"
                else:
                    swizzle = ".wzyx"
        else:
            if is_destination:
                mask = ".xyzw"
            else:
                swizzle = ".xyzw"

        if ".bank=" in token:
            raise ValueError(f"Invalid syntax: .bank= not supported, use @ for bank specification")

        if reg not in register_map:
            raise ValueError(f"Invalid register: {reg}")

        return {
            "reg": to_bin(register_map[reg], 8),
            "bank": bank_map[bank],
            "swizzle": parse_swizzle(swizzle) if not is_destination else "00000000",
            "mask": parse_mask(mask) if is_destination else "1111",
            "negate": negate,
            "absolute": absolute
        }

    if spec["type"] == "R0":
        if len(tokens) != 1:
            raise ValueError(f"{mnemonic} expects no operands, got {len(tokens)-1}")

    elif spec["type"] == "R2":
        if len(tokens) != 3:
            raise ValueError(f"{mnemonic} expects 2 operands, got {len(tokens)-1}")
        rd_info = parse_register(tokens[1], is_destination=True)
        rs1_info = parse_register(tokens[2])
        resreg = rd_info["reg"]
        resbank = rd_info["bank"]
        mask = rd_info["mask"]
        op1reg = rs1_info["reg"]
        op1bank = rs1_info["bank"]
        op1swizzle = rs1_info["swizzle"]
        op1negate = rs1_info["negate"]
        op1absolute = rs1_info["absolute"]

    elif spec["type"] == "R3":
        if len(tokens) != 4:
            raise ValueError(f"{mnemonic} expects 3 operands, got {len(tokens)-1}")
        rd_info = parse_register(tokens[1], is_destination=True)
        rs1_info = parse_register(tokens[2])
        rs2_info = parse_register(tokens[3])
        resreg = rd_info["reg"]
        resbank = rd_info["bank"]
        mask = rd_info["mask"]
        op1reg = rs1_info["reg"]
        op1bank = rs1_info["bank"]
        op1swizzle = rs1_info["swizzle"]
        op1negate = rs1_info["negate"]
        op1absolute = rs1_info["absolute"]
        op2reg = rs2_info["reg"]
        op2bank = rs2_info["bank"]
        op2swizzle = rs2_info["swizzle"]
        op2negate = rs2_info["negate"]
        op2absolute = rs2_info["absolute"]

    elif spec["type"] == "R4":
        if len(tokens) != 5:
            raise ValueError(f"{mnemonic} expects 4 operands, got {len(tokens)-1}")
        rd_info = parse_register(tokens[1], is_destination=True)
        rs1_info = parse_register(tokens[2])
        rs2_info = parse_register(tokens[3])
        rs3_info = parse_register(tokens[4])
        resreg = rd_info["reg"]
        resbank = rd_info["bank"]
        mask = rd_info["mask"]
        op1reg = rs1_info["reg"]
        op1bank = rs1_info["bank"]
        op1swizzle = rs1_info["swizzle"]
        op1negate = rs1_info["negate"]
        op1absolute = rs1_info["absolute"]
        op2reg = rs2_info["reg"]
        op2bank = rs2_info["bank"]
        op2swizzle = rs2_info["swizzle"]
        op2negate = rs2_info["negate"]
        op2absolute = rs2_info["absolute"]
        op3reg = rs3_info["reg"]
        op3bank = rs3_info["bank"]
        op3swizzle = rs3_info["swizzle"]
        op3negate = rs3_info["negate"]
        op3absolute = rs3_info["absolute"]

    elif spec["type"] == "I":
        if len(tokens) != 4:
            raise ValueError(f"{mnemonic} expects 3 operands, got {len(tokens)-1}")
        rd_info = parse_register(tokens[1], is_destination=True)
        rs1_info = parse_register(tokens[2])
        resreg = rd_info["reg"]
        resbank = rd_info["bank"]
        mask = rd_info["mask"]
        op1reg = rs1_info["reg"]
        op1bank = rs1_info["bank"]
        op1swizzle = rs1_info["swizzle"]
        op1negate = rs1_info["negate"]
        op1absolute = rs1_info["absolute"]
        try:
            imm = float(tokens[3])
            import struct
            immediate = format(struct.unpack('!I', struct.pack('!f', imm))[0], '032b')
            op2bank = "110"
        except ValueError:
            raise ValueError(f"Invalid immediate value: {tokens[3]}")

    quadword0 = (
        "00" +
        funct +            # 5 bits [61:57]
        rm +               # 3 bits [56:54]
        reserved +         # 16 bits [53:40]
        mask +             # 4 bits [39:36]
        saturatedres +     # 1 bit [35]
        resbank +          # 3 bits [34:32]
        op3absolute +      # 1 bit [31]
        op3negate +        # 1 bit [30]
        op3bank +          # 3 bits [29:27]
        op2absolute +      # 1 bit [26]
        op2negate +        # 1 bit [25]
        op2bank +          # 3 bits [24:22]
        op1absolute +      # 1 bit [21]
        op1negate +        # 1 bit [20]
        op1bank +          # 3 bits [19:17]
        predreg +          # 5 bits [16:12]
        invertpred +       # 1 bit [11]
        predicated +       # 1 bit [10]
        waitpoint +        # 1 bit [9]
        endflag +          # 1 bit [8]
        opcode             # 8 bits [7:0]
    )

    quadword1 = (
        reserved_q1 +
        op3swizzle +
        op3reg +
        op2swizzle +
        op2reg +
        resreg +
        op1swizzle +
        op1reg
    )

    if spec["type"] == "I":
        quadword1 = (
            reserved_q1 +
            op3swizzle +
            op3reg +
            immediate
        )

    machine_code = quadword1 + quadword0
    return to_hex(machine_code)

def write_hex_to_file(hex_list, filename):
    with open(filename, "w") as f:
        for h in hex_list:
            f.write(h + "\n")

def check_syntax(instructions, line_numbers, label_map):
    errors = []
    valid_mnemonics = set(instruction_map.keys())
    r0_instructions = {"nop"}  # Bỏ class khỏi R0
    r2_instructions = {"class", "cvt_f2i", "cvtu_f2i", "cvt_i2f", "cvtu_i2f"}  # Thêm class vào R2
    r3_instructions = {"add", "sub", "mul", "sgnj", "sgjn", "sgjx", "min", "max", "seq", "slt", "sle"}
    r4_instructions = {"madd", "msub", "nmadd", "nmsub"}
    i_instructions = {"addi", "subi", "muli", "mini", "maxi", "seqi", "slti", "slei"}

    for idx, (instr, line_num) in enumerate(zip(instructions, line_numbers)):
        tokens = re.split(r"[\s,]+", instr.strip())
        tokens = [t for t in tokens if t]
        if not tokens:
            errors.append(f"Line {line_num}: Empty instruction")
            continue
        mnemonic = tokens[0].lower()
        mnemonic_clean = mnemonic.replace("_sat", "")
        if ".rm=" in mnemonic_clean:
            mnemonic_clean = mnemonic_clean.split(".rm=")[0]

        if mnemonic_clean not in valid_mnemonics:
            errors.append(f"Line {line_num}: Invalid instruction '{mnemonic}'")
            continue

        def validate_register(token, field, is_destination=False):
            token_clean = token.split("@")[0].split(".")[0]
            if token_clean.startswith("-") or token_clean.startswith("|"):
                token_clean = token_clean[1:]
            if token_clean.startswith("-") or token_clean.startswith("|"):
                token_clean = token_clean[1:]
            if not token_clean.startswith("r"):
                return f"Invalid register format '{token_clean}' in {field}"
            try:
                reg_num = int(token_clean[1:])
                if reg_num > 31:
                    return f"Register '{token_clean}' exceeds r31 in {field}"
                if token_clean not in register_map:
                    return f"Invalid register '{token_clean}' in {field}"
            except ValueError:
                return f"Invalid register format '{token_clean}' in {field}"

            if "@" in token:
                bank = token.split("@")[1].split(".")[0].lower()
                if bank not in bank_map:
                    return f"Invalid bank '{bank}' in {field}"
                if is_destination and bank_map[bank] in ["000"]:
                    return f"Cannot write to read-only bank '{bank}' in {field}"
            return None

        def validate_swizzle(token, field):
            if "." in token:
                swizzle = token.split(".")[1]
                if len(swizzle) != 4 or not all(c in swizzle_map for c in swizzle):
                    return f"Invalid swizzle pattern '.{swizzle}' in {field}"
            return None

        def validate_mask(token, field):
            if "." in token:
                mask = token.split(".")[1]
                if not mask or len(mask) > 4 or not all(c in swizzle_map for c in mask):
                    return f"Invalid mask pattern '.{mask}' in {field}"
            return None

        if mnemonic_clean in r0_instructions:
            if len(tokens) != 1:
                errors.append(f"Line {line_num}: Expected 0 operands for '{mnemonic}', got {len(tokens)-1}")
                continue

        elif mnemonic_clean in r2_instructions:
            if len(tokens) != 3:
                errors.append(f"Line {line_num}: Expected 2 operands for '{mnemonic_clean}', got {len(tokens)-1}")
                continue
            rd_error = validate_register(tokens[1], "rd", is_destination=True)
            rs1_error = validate_register(tokens[2], "rs1")
            rd_mask_error = validate_mask(tokens[1], "rd")
            rs1_swizzle_error = validate_swizzle(tokens[2], "rs1")
            for error in (rd_error, rs1_error, rd_mask_error, rs1_swizzle_error):
                if error:
                    errors.append(f"Line {line_num}: {error}")

        elif mnemonic_clean in r3_instructions:
            if len(tokens) != 4:
                errors.append(f"Line {line_num}: Expected 3 operands for '{mnemonic_clean}', got {len(tokens)-1}")
                continue
            rd_error = validate_register(tokens[1], "rd", is_destination=True)
            rs1_error = validate_register(tokens[2], "rs1")
            rs2_error = validate_register(tokens[3], "rs2")
            rd_mask_error = validate_mask(tokens[1], "rd")
            rs1_swizzle_error = validate_swizzle(tokens[2], "rs1")
            rs2_swizzle_error = validate_swizzle(tokens[3], "rs2")
            for error in (rd_error, rs1_error, rs2_error, rd_mask_error, rs1_swizzle_error, rs2_swizzle_error):
                if error:
                    errors.append(f"Line {line_num}: {error}")

        elif mnemonic_clean in r4_instructions:
            if len(tokens) != 5:
                errors.append(f"Line {line_num}: Expected 4 operands for '{mnemonic_clean}', got {len(tokens)-1}")
                continue
            rd_error = validate_register(tokens[1], "rd", is_destination=True)
            rs1_error = validate_register(tokens[2], "rs1")
            rs2_error = validate_register(tokens[3], "rs2")
            rs3_error = validate_register(tokens[4], "rs3")
            rd_mask_error = validate_mask(tokens[1], "rd")
            rs1_swizzle_error = validate_swizzle(tokens[2], "rs1")
            rs2_swizzle_error = validate_swizzle(tokens[3], "rs2")
            rs3_swizzle_error = validate_swizzle(tokens[4], "rs3")
            for error in (rd_error, rs1_error, rs2_error, rs3_error, rd_mask_error, rs1_swizzle_error, rs2_swizzle_error, rs3_swizzle_error):
                if error:
                    errors.append(f"Line {line_num}: {error}")

        elif mnemonic_clean in i_instructions:
            if len(tokens) != 4:
                errors.append(f"Line {line_num}: Expected 3 operands for '{mnemonic_clean}', got {len(tokens)-1}")
                continue
            rd_error = validate_register(tokens[1], "rd", is_destination=True)
            rs1_error = validate_register(tokens[2], "rs1")
            rd_mask_error = validate_mask(tokens[1], "rd")
            rs1_swizzle_error = validate_swizzle(tokens[2], "rs1")
            try:
                float(tokens[3])
            except ValueError:
                errors.append(f"Line {line_num}: Invalid immediate value '{tokens[3]}'")
            for error in (rd_error, rs1_error, rd_mask_error, rs1_swizzle_error):
                if error:
                    errors.append(f"Line {line_num}: {error}")

    return errors

def read_instructions_from_file(filename):
    with open(filename, "r") as f:
        lines = []
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "#" in line:
                line = line.split("#")[0].strip()
            if line:
                lines.append((line, line_num))
        return lines

def preprocess_labels(instructions):
    label_map = {}
    cleaned_instructions = []
    line_numbers = []
    valid_mnemonics = set(instruction_map.keys())

    for instr, line_num in instructions:
        instr = instr.strip()
        if ':' in instr:
            label = instr.split(':')[0].strip()
            if label in label_map:
                raise ValueError(f"Line {line_num}: Duplicate label '{label}'")
            if label.lower() in valid_mnemonics:
                raise ValueError(f"Line {line_num}: Label '{label}' conflicts with instruction mnemonic")
            if not label:
                raise ValueError(f"Line {line_num}: Empty label name")
            label_map[label] = len(cleaned_instructions)
            if instr.endswith(':'):
                continue
            else:
                instruction = instr.split(':')[1].strip()
                if instruction:
                    cleaned_instructions.append(instruction)
                    line_numbers.append(line_num)
        else:
            cleaned_instructions.append(instr)
            line_numbers.append(line_num)

    return label_map, cleaned_instructions, line_numbers

if __name__ == "__main__":
    input_file = "./input_instr.txt"
    output_file = "../include/imem_data.mem"

    try:
        raw_instructions = read_instructions_from_file(input_file)
        label_map, instructions, line_numbers = preprocess_labels(raw_instructions)
        errors = check_syntax(instructions, line_numbers, label_map)
        if errors:
            print("❌ Syntax errors found:")
            for error in errors:
                print(error)
            open(output_file, "w").close()
            exit(1)
        hex_codes = [encode_instruction(instr, idx, label_map) for idx, instr in enumerate(instructions)]
        write_hex_to_file(hex_codes, output_file)
        print(f"✅ Successfully converted {len(hex_codes)} instructions to machine code (HEX format) → {output_file}")
    except Exception as e:
        print(f"❌ Error: {e}")
        open(output_file, "w").close()