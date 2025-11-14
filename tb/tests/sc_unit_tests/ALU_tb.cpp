#include "Vdut.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "gtest/gtest.h"
#include <memory>

// Test fixture for ALU module
class AluTester : public ::testing::Test {
protected:
    std::unique_ptr<Vdut> ALU;

    void SetUp() override {
        ALU = std::make_unique<Vdut>();
    }

    void TearDown() override {
        ALU->final();
    }

    // Helper function to test ALU operations (only checks ALUout)
    void testALU(uint32_t op1, uint32_t op2, uint8_t ctrl, uint32_t expected_ALUout) {
        ALU->ALUop1 = op1;
        ALU->ALUop2 = op2;
        ALU->ALUctrl = ctrl;
        ALU->eval();
        EXPECT_EQ(ALU->ALUout, expected_ALUout);
    }

    // Helper function to test EQ output (for branch comparisons)
    void testEQ(uint32_t op1, uint32_t op2, uint8_t ctrl, uint32_t expected_EQ) {
        ALU->ALUop1 = op1;
        ALU->ALUop2 = op2;
        ALU->ALUctrl = ctrl;
        ALU->eval();
        EXPECT_EQ(ALU->EQ, expected_EQ);
    }
};

// ADD instruction tests (ALUctrl = 0b0000)
TEST_F(AluTester, AddTests) {
    testALU(3, 5, 0b0000, 8);
    testALU(-1, 10, 0b0000, 9);
    testALU(100, 5, 0b0000, 105);
    testALU(0xFFFFFFFF, 1, 0b0000, 0);  // Overflow
}

// SUB instruction tests (ALUctrl = 0b1000)
TEST_F(AluTester, SubTests) {
    testALU(10, 5, 0b1000, 5);
    testALU(5, 10, 0b1000, 0xFFFFFFFB);  // Negative result
    testALU(100, 100, 0b1000, 0);
    testALU(0, 1, 0b1000, 0xFFFFFFFF);   // 0 - 1 = -1
}

// AND instruction tests (ALUctrl = 0b0111 or 0b1111)
TEST_F(AluTester, AndTests) {
    testALU(0xFF, 0x0F, 0b0111, 0x0F);
    testALU(0xAAAA, 0x5555, 0b0111, 0);
    testALU(0xFFFF, 0xFFFF, 0b0111, 0xFFFF);
    testALU(0x12345678, 0xF0F0F0F0, 0b1111, 0x10305070);
}

// OR instruction tests (ALUctrl = 0b0110 or 0b1110)
TEST_F(AluTester, OrTests) {
    testALU(0xF0, 0x0F, 0b0110, 0xFF);
    testALU(0, 0, 0b0110, 0);
    testALU(0xAAAA, 0x5555, 0b0110, 0xFFFF);
    testALU(0x12345678, 0x87654321, 0b1110, 0x97755779);
}

// XOR instruction tests (ALUctrl = 0b0100 or 0b1100)
TEST_F(AluTester, XorTests) {
    testALU(0xFF, 0xFF, 0b0100, 0);
    testALU(0xF0, 0x0F, 0b0100, 0xFF);
    testALU(0xAAAA, 0x5555, 0b0100, 0xFFFF);
    testALU(5, 3, 0b1100, 6);
}

// SLL (Shift Left Logical) tests (ALUctrl = 0b0001 or 0b1001)
TEST_F(AluTester, SllTests) {
    testALU(1, 0, 0b0001, 1);
    testALU(1, 1, 0b0001, 2);
    testALU(1, 4, 0b0001, 16);
    testALU(0xFF, 8, 0b1001, 0xFF00);
    testALU(1, 31, 0b0001, 0x80000000);
}

// SRL (Shift Right Logical) tests (ALUctrl = 0b0101)
TEST_F(AluTester, SrlTests) {
    testALU(16, 4, 0b0101, 1);
    testALU(0xFF00, 8, 0b0101, 0xFF);
    testALU(0x80000000, 1, 0b0101, 0x40000000);
    testALU(0xFFFFFFFF, 4, 0b0101, 0x0FFFFFFF);
}

// SRA (Shift Right Arithmetic) tests (ALUctrl = 0b1101)
TEST_F(AluTester, SraTests) {
    testALU(16, 4, 0b1101, 1);
    testALU(0x80000000, 1, 0b1101, 0xC0000000);  // Sign extend
    testALU(0xFFFFFFFF, 4, 0b1101, 0xFFFFFFFF);  // All 1s stays all 1s
    testALU(0x7FFFFFFF, 4, 0b1101, 0x07FFFFFF);  // Positive number
}

// SLT (Set Less Than signed) tests (ALUctrl = 0b0010 or 0b1010)
TEST_F(AluTester, SltTests) {
    testALU(5, 10, 0b0010, 1);    // 5 < 10 = true
    testALU(10, 5, 0b0010, 0);    // 10 < 5 = false
    testALU(5, 5, 0b0010, 0);     // 5 < 5 = false
    testALU(-1, 1, 0b1010, 1);    // -1 < 1 = true (signed)
    testALU(1, -1, 0b0010, 0);    // 1 < -1 = false (signed)
}

// SLTU (Set Less Than Unsigned) tests (ALUctrl = 0b0011 or 0b1011)
TEST_F(AluTester, SltuTests) {
    testALU(5, 10, 0b0011, 1);           // 5 < 10 = true
    testALU(10, 5, 0b0011, 0);           // 10 < 5 = false
    testALU(0xFFFFFFFF, 1, 0b1011, 0);   // Max unsigned > 1
    testALU(1, 0xFFFFFFFF, 0b0011, 1);   // 1 < Max unsigned
}

// BEQ (Branch if Equal) tests - ALUctrl[2:0] = 0b000
TEST_F(AluTester, BeqTests) {
    testEQ(5, 5, 0b0000, 1);      // Equal
    testEQ(5, 10, 0b0000, 0);     // Not equal
    testEQ(0, 0, 0b1000, 1);      // Equal (ALUctrl[2:0]=000)
    testEQ(-1, -1, 0b0000, 1);    // Equal negative
}

// BNE (Branch if Not Equal) tests - ALUctrl[2:0] = 0b001
TEST_F(AluTester, BneTests) {
    testEQ(5, 10, 0b0001, 1);     // Not equal
    testEQ(5, 5, 0b1001, 0);      // Equal (ALUctrl[2:0]=001)
    testEQ(0, 1, 0b0001, 1);      // Not equal
}

// BLT (Branch if Less Than signed) tests - ALUctrl[2:0] = 0b100
TEST_F(AluTester, BltTests) {
    testEQ(5, 10, 0b0100, 1);     // 5 < 10
    testEQ(10, 5, 0b1100, 0);     // 10 >= 5 (ALUctrl[2:0]=100)
    testEQ(-1, 1, 0b0100, 1);     // -1 < 1
    testEQ(1, -1, 0b1100, 0);     // 1 >= -1
}

// BGE (Branch if Greater or Equal signed) tests - ALUctrl[2:0] = 0b101
TEST_F(AluTester, BgeTests) {
    testEQ(10, 5, 0b0101, 1);     // 10 >= 5
    testEQ(5, 10, 0b1101, 0);     // 5 < 10 (ALUctrl[2:0]=101)
    testEQ(5, 5, 0b0101, 1);      // 5 >= 5
    testEQ(-1, 1, 0b1101, 0);     // -1 < 1
}

// BLTU (Branch if Less Than Unsigned) tests - ALUctrl[2:0] = 0b110
TEST_F(AluTester, BltuTests) {
    testEQ(5, 10, 0b0110, 1);            // 5 < 10
    testEQ(10, 5, 0b1110, 0);            // 10 >= 5 (ALUctrl[2:0]=110)
    testEQ(1, 0xFFFFFFFF, 0b0110, 1);    // 1 < max
    testEQ(0xFFFFFFFF, 1, 0b1110, 0);    // max >= 1
}

// BGEU (Branch if Greater or Equal Unsigned) tests - ALUctrl[2:0] = 0b111
TEST_F(AluTester, BgeuTests) {
    testEQ(10, 5, 0b0111, 1);            // 10 >= 5
    testEQ(5, 10, 0b1111, 0);            // 5 < 10 (ALUctrl[2:0]=111)
    testEQ(0xFFFFFFFF, 1, 0b0111, 1);    // max >= 1
    testEQ(1, 0xFFFFFFFF, 0b1111, 0);    // 1 < max
}

// Edge case tests
TEST_F(AluTester, EdgeCaseTests) {
    // Zero operands
    testALU(0, 0, 0b0000, 0);   // ADD: 0+0=0
    testALU(0, 0, 0b1000, 0);   // SUB: 0-0=0

    // Max values
    testALU(0xFFFFFFFF, 0xFFFFFFFF, 0b0000, 0xFFFFFFFE);  // ADD with overflow
    testALU(0xFFFFFFFF, 1, 0b1000, 0xFFFFFFFE);           // SUB from max

    // One operand zero
    testALU(0, 100, 0b0000, 100);
    testALU(100, 0, 0b1000, 100);
    
    // EQ tests with zero
    testEQ(0, 0, 0b0000, 1);   // 0 == 0
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

