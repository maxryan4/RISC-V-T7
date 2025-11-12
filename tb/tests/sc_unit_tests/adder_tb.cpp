#include "Vdut.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "gtest/gtest.h"
#include <memory>

// Test fixture for adder module
class AdderTest : public ::testing::Test {
protected:
    std::unique_ptr<Vdut> adder;

    void SetUp() override {
        adder = std::make_unique<Vdut>();
    }

    void TearDown() override {
        adder->final();
    }

    // Helper function to test addition
    void testAddition(uint32_t a_val, uint32_t b_val, uint32_t expected) {
        adder->in0 = a_val;
        adder->in1 = b_val;
        adder->eval();          EXPECT_EQ(adder->out, expected)
            << "Failed for a=" << a_val << ", b=" << b_val;
    }
};

// Basic addition test
TEST_F(AdderTest, BasicAddition) {
    testAddition(3, 5, 8);
    testAddition(10, 20, 30);
    testAddition(0, 0, 0);
}

// subtraction test
TEST_F(AdderTest, SubTest) {
  testAddition(-4, -19, -23);
  testAddition(-103, 93, -10);
}


// edge case tests
TEST_F(AdderTest, EdgeAddition) {
  testAddition(4294967295, 1, 0);
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

