#include "Vdut.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "gtest/gtest.h"
#include <memory>


class ControlUnitTester : public ::testing::Test {
protected:
    std::unique_ptr<Vdut> control_unit;

    void SetUp() override {
        control_unit = std::make_unique<Vdut>();
    }

    void TearDown() override {
        control_unit->final();
    }

    // Test control signals for a given instruction
    void testInstruction(uint32_t instr, uint8_t EQ,
                        uint8_t exp_RegWrite, uint8_t exp_ALUctrl, uint8_t exp_ALUsrc,
                        uint8_t exp_ImmSrc, uint8_t exp_PCsrc, uint8_t exp_destsrc,
                        uint8_t exp_memCtrl, uint8_t exp_MemWrite, uint8_t exp_UI_control,
                        uint8_t exp_RD1_control, uint8_t exp_PC_RD1_control, uint8_t exp_four_imm_control) {
        control_unit->instr = instr;
        control_unit->EQ = EQ;
        control_unit->eval();

        EXPECT_EQ(control_unit->RegWrite, exp_RegWrite) << "RegWrite mismatch for instr: 0x" << std::hex << instr;
        EXPECT_EQ(control_unit->ALUctrl, exp_ALUctrl) << "ALUctrl mismatch for instr: 0x" << std::hex << instr;
        EXPECT_EQ(control_unit->ALUsrc, exp_ALUsrc) << "ALUsrc mismatch for instr: 0x" << std::hex << instr;
        EXPECT_EQ(control_unit->ImmSrc, exp_ImmSrc) << "ImmSrc mismatch for instr: 0x" << std::hex << instr;
        EXPECT_EQ(control_unit->PCsrc, exp_PCsrc) << "PCsrc mismatch for instr: 0x" << std::hex << instr;
        EXPECT_EQ(control_unit->destsrc, exp_destsrc) << "destsrc mismatch for instr: 0x" << std::hex << instr;
        EXPECT_EQ(control_unit->memCtrl, exp_memCtrl) << "memCtrl mismatch for instr: 0x" << std::hex << instr;
        EXPECT_EQ(control_unit->MemWrite, exp_MemWrite) << "MemWrite mismatch for instr: 0x" << std::hex << instr;
        EXPECT_EQ(control_unit->UI_control, exp_UI_control) << "UI_control mismatch for instr: 0x" << std::hex << instr;
        EXPECT_EQ(control_unit->RD1_control, exp_RD1_control) << "RD1_control mismatch for instr: 0x" << std::hex << instr;
        EXPECT_EQ(control_unit->PC_RD1_control, exp_PC_RD1_control) << "PC_RD1_control mismatch for instr: 0x" << std::hex << instr;
        EXPECT_EQ(control_unit->four_imm_control, exp_four_imm_control) << "four_imm_control mismatch for instr: 0x" << std::hex << instr;
    }
};

// R-type instructions (opcode 0110011)
TEST_F(ControlUnitTester, RType_ADD) {
    // ADD: funct7=0000000, funct3=000, opcode=0110011
    // instr[30]=0, instr[14:12]=000 -> ALUctrl=0000
    testInstruction(0x00000033, 0, 1, 0b0000, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, RType_SUB) {
    // SUB: funct7=0100000, funct3=000, opcode=0110011
    // instr[30]=1, instr[14:12]=000 -> ALUctrl=1000
    testInstruction(0x40000033, 0, 1, 0b1000, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, RType_AND) {
    // AND: funct7=0000000, funct3=111, opcode=0110011
    // instr[30]=0, instr[14:12]=111 -> ALUctrl=0111
    testInstruction(0x00007033, 0, 1, 0b0111, 0, 0, 0, 0, 7, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, RType_OR) {
    // OR: funct7=0000000, funct3=110, opcode=0110011
    // instr[30]=0, instr[14:12]=110 -> ALUctrl=0110
    testInstruction(0x00006033, 0, 1, 0b0110, 0, 0, 0, 0, 6, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, RType_XOR) {
    // XOR: funct7=0000000, funct3=100, opcode=0110011
    // instr[30]=0, instr[14:12]=100 -> ALUctrl=0100
    testInstruction(0x00004033, 0, 1, 0b0100, 0, 0, 0, 0, 4, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, RType_SLL) {
    // SLL: funct7=0000000, funct3=001, opcode=0110011
    testInstruction(0x00001033, 0, 1, 0b0001, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, RType_SRL) {
    // SRL: funct7=0000000, funct3=101, opcode=0110011
    testInstruction(0x00005033, 0, 1, 0b0101, 0, 0, 0, 0, 5, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, RType_SRA) {
    // SRA: funct7=0100000, funct3=101, opcode=0110011
    testInstruction(0x40005033, 0, 1, 0b1101, 0, 0, 0, 0, 5, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, RType_SLT) {
    // SLT: funct7=0000000, funct3=010, opcode=0110011
    testInstruction(0x00002033, 0, 1, 0b0010, 0, 0, 0, 0, 2, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, RType_SLTU) {
    // SLTU: funct7=0000000, funct3=011, opcode=0110011
    testInstruction(0x00003033, 0, 1, 0b0011, 0, 0, 0, 0, 3, 0, 1, 1, 1, 1);
}

// I-type instructions (opcode 0010011)
TEST_F(ControlUnitTester, IType_ADDI) {
    // ADDI: funct3=000, opcode=0010011
    testInstruction(0x00000013, 0, 1, 0b0000, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, IType_ANDI) {
    // ANDI: funct3=111, opcode=0010011
    testInstruction(0x00007013, 0, 1, 0b0111, 1, 0, 0, 0, 7, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, IType_ORI) {
    // ORI: funct3=110, opcode=0010011
    testInstruction(0x00006013, 0, 1, 0b0110, 1, 0, 0, 0, 6, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, IType_XORI) {
    // XORI: funct3=100, opcode=0010011
    testInstruction(0x00004013, 0, 1, 0b0100, 1, 0, 0, 0, 4, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, IType_SLLI) {
    // SLLI: funct3=001, opcode=0010011
    testInstruction(0x00001013, 0, 1, 0b0001, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, IType_SRLI) {
    // SRLI: funct3=101, opcode=0010011, bit[30]=0
    testInstruction(0x00005013, 0, 1, 0b0101, 1, 0, 0, 0, 5, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, IType_SRAI) {
    // SRAI: funct3=101, opcode=0010011, bit[30]=1
    testInstruction(0x40005013, 0, 1, 0b1101, 1, 0, 0, 0, 5, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, IType_SLTI) {
    // SLTI: funct3=010, opcode=0010011
    testInstruction(0x00002013, 0, 1, 0b0010, 1, 0, 0, 0, 2, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, IType_SLTIU) {
    // SLTIU: funct3=011, opcode=0010011
    testInstruction(0x00003013, 0, 1, 0b0011, 1, 0, 0, 0, 3, 0, 1, 1, 1, 1);
}

// Load instructions (opcode 0000011)
TEST_F(ControlUnitTester, Load_LW) {
    // LW: funct3=010, opcode=0000011
    testInstruction(0x00002003, 0, 1, 0b0000, 1, 0, 0, 1, 2, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, Load_LH) {
    // LH: funct3=001, opcode=0000011
    testInstruction(0x00001003, 0, 1, 0b0000, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, Load_LB) {
    // LB: funct3=000, opcode=0000011
    testInstruction(0x00000003, 0, 1, 0b0000, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, Load_LHU) {
    // LHU: funct3=101, opcode=0000011
    testInstruction(0x00005003, 0, 1, 0b0000, 1, 0, 0, 1, 5, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, Load_LBU) {
    // LBU: funct3=100, opcode=0000011
    testInstruction(0x00004003, 0, 1, 0b0000, 1, 0, 0, 1, 4, 0, 1, 1, 1, 1);
}

// Store instructions (opcode 0100011)
TEST_F(ControlUnitTester, Store_SW) {
    // SW: funct3=010, opcode=0100011
    testInstruction(0x00002023, 0, 0, 0b0000, 1, 2, 0, 0, 2, 1, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, Store_SH) {
    // SH: funct3=001, opcode=0100011
    testInstruction(0x00001023, 0, 0, 0b0000, 1, 2, 0, 0, 1, 1, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, Store_SB) {
    // SB: funct3=000, opcode=0100011
    testInstruction(0x00000023, 0, 0, 0b0000, 1, 2, 0, 0, 0, 1, 1, 1, 1, 1);
}

// Branch instructions (opcode 1100011)
TEST_F(ControlUnitTester, Branch_BEQ_Taken) {
    // BEQ: funct3=000, opcode=1100011, EQ=1
    testInstruction(0x00000063, 1, 0, 0b0000, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, Branch_BEQ_NotTaken) {
    // BEQ: funct3=000, opcode=1100011, EQ=0
    testInstruction(0x00000063, 0, 0, 0b0000, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, Branch_BNE) {
    // BNE: funct3=001, opcode=1100011
    testInstruction(0x00001063, 0, 0, 0b0001, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, Branch_BLT) {
    // BLT: funct3=100, opcode=1100011
    testInstruction(0x00004063, 0, 0, 0b0100, 0, 1, 0, 0, 4, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, Branch_BGE) {
    // BGE: funct3=101, opcode=1100011
    testInstruction(0x00005063, 0, 0, 0b0101, 0, 1, 0, 0, 5, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, Branch_BLTU) {
    // BLTU: funct3=110, opcode=1100011
    testInstruction(0x00006063, 0, 0, 0b0110, 0, 1, 0, 0, 6, 0, 1, 1, 1, 1);
}

TEST_F(ControlUnitTester, Branch_BGEU) {
    // BGEU: funct3=111, opcode=1100011
    testInstruction(0x00007063, 0, 0, 0b0111, 0, 1, 0, 0, 7, 0, 1, 1, 1, 1);
}

// LUI (opcode 0110111)
TEST_F(ControlUnitTester, LUI) {
    // LUI: opcode=0110111
    testInstruction(0x00000037, 0, 1, 0b0000, 1, 3, 0, 0, 0, 0, 0, 0, 1, 1);
}

// AUIPC (opcode 0010111)
TEST_F(ControlUnitTester, AUIPC) {
    // AUIPC: opcode=0010111
    testInstruction(0x00000017, 0, 1, 0b0000, 1, 3, 0, 0, 0, 0, 1, 0, 1, 1);
}

// JAL (opcode 1101111)
TEST_F(ControlUnitTester, JAL) {
    // JAL: opcode=1101111
    testInstruction(0x0000006F, 0, 1, 0b0000, 1, 4, 1, 0, 0, 0, 1, 0, 1, 0);
}

// JALR (opcode 1100111)
TEST_F(ControlUnitTester, JALR) {
    // JALR: opcode=1100111
    testInstruction(0x00000067, 0, 1, 0b0000, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0);
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}

