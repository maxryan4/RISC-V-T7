#include "Vdut.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "gtest/gtest.h"
#include <memory>

// Test fixture for hazard_unit module
class HazardUnitTest : public ::testing::Test {
protected:
    std::unique_ptr<Vdut> hazard_unit;

    void SetUp() override {
        hazard_unit = std::make_unique<Vdut>();
    }

    void TearDown() override {
        hazard_unit->final();
    }

    // Helper function to test hazard detection
    void testHazard(uint8_t execute_reg, uint8_t valid_e, uint8_t valid_m, uint8_t load_m,
                    uint8_t valid_w, uint8_t dest_m, uint8_t dest_w, uint32_t data_m,
                    uint32_t data_w, uint8_t expected_forward, uint8_t expected_hazard,
                    uint32_t expected_data) {

        hazard_unit->execute_reg = execute_reg;
        hazard_unit->valid_e = valid_e;
        hazard_unit->valid_m = valid_m;
        hazard_unit->load_m = load_m;
        hazard_unit->valid_w = valid_w;
        hazard_unit->dest_m = dest_m;
        hazard_unit->dest_w = dest_w;
        hazard_unit->data_m = data_m;
        hazard_unit->data_w = data_w;

        hazard_unit->eval();

        EXPECT_EQ(hazard_unit->forward, expected_forward)
            << "Forward mismatch: execute_reg=" << (int)execute_reg
            << " dest_m=" << (int)dest_m << " dest_w=" << (int)dest_w;
        EXPECT_EQ(hazard_unit->hazard, expected_hazard)
            << "Hazard mismatch: load_m=" << (int)load_m;
        EXPECT_EQ(hazard_unit->data, expected_data)
            << "Data mismatch";
    }
};

// Test 1: EX/MEM Data Hazard - Forward from MEM stage (no load)
// Scenario: add x1, x2, x3 (in MEM stage, x1=dest_m=1)
//           add x4, x1, x5 (in EX stage, x1=execute_reg=1)
// Expected: forward=1, hazard=0, data forwarded from MEM stage
TEST_F(HazardUnitTest, DataHazard_ForwardFromMEM) {
    testHazard(
        1,      // execute_reg = x1 (instruction in EX needs x1)
        1,      // valid_e = 1 (instruction in EX is valid)
        1,      // valid_m = 1 (instruction in MEM is valid)
        0,      // load_m = 0 (not a load instruction)
        0,      // valid_w = 0 (no writeback yet)
        1,      // dest_m = x1 (instruction in MEM writes to x1)
        0,      // dest_w = 0
        0xABCD, // data_m = value from MEM stage
        0,      // data_w = 0
        1,      // expected_forward = 1 (can forward)
        0,      // expected_hazard = 0 (no stall needed)
        0xABCD  // expected_data = data from MEM
    );
}

// Test 2: MEM/WB Data Hazard - Forward from WB stage
// Scenario: add x2, x3, x4 (in WB stage, x2=dest_w=2)
//           sub x5, x2, x6 (in EX stage, x2=execute_reg=2)
// Expected: forward=1, hazard=0, data forwarded from WB stage
TEST_F(HazardUnitTest, DataHazard_ForwardFromWB) {
    testHazard(
        2,      // execute_reg = x2
        1,      // valid_e = 1
        0,      // valid_m = 0 (no instruction in MEM)
        0,      // load_m = 0
        1,      // valid_w = 1 (instruction in WB is valid)
        0,      // dest_m = 0
        2,      // dest_w = x2 (instruction in WB writes to x2)
        0,      // data_m = 0
        0x1234, // data_w = value from WB stage
        1,      // expected_forward = 1
        0,      // expected_hazard = 0
        0x1234  // expected_data = data from WB
    );
}

// Test 3: Load-Use Hazard - Stall required
// Scenario: lw x3, 0(x10) (in MEM stage, load_m=1, x3=dest_m=3)
//           add x4, x3, x5 (in EX stage, x3=execute_reg=3)
// Expected: forward=0, hazard=1, pipeline must stall
TEST_F(HazardUnitTest, DataHazard_LoadUseStall) {
    testHazard(
        3,      // execute_reg = x3
        1,      // valid_e = 1
        1,      // valid_m = 1
        1,      // load_m = 1 (LOAD instruction in MEM)
        0,      // valid_w = 0
        3,      // dest_m = x3 (load writes to x3)
        0,      // dest_w = 0
        0x5678, // data_m = loaded value (not ready yet)
        0,      // data_w = 0
        0,      // expected_forward = 0 (cannot forward from load)
        1,      // expected_hazard = 1 (STALL required!)
        0x5678  // expected_data = data from MEM (will be ready after stall)
    );
}

// Test 4: No Hazard - Different registers
// Scenario: add x5, x6, x7 (in MEM, dest_m=5)
//           sub x8, x9, x10 (in EX, needs x9, not x5)
// Expected: forward=0, hazard=0, no dependency
TEST_F(HazardUnitTest, DataHazard_NoDependency) {
    testHazard(
        9,      // execute_reg = x9
        1,      // valid_e = 1
        1,      // valid_m = 1
        0,      // load_m = 0
        1,      // valid_w = 1
        5,      // dest_m = x5 (different register)
        8,      // dest_w = x8 (different register)
        0x1111, // data_m
        0x2222, // data_w
        0,      // expected_forward = 0 (no match)
        0,      // expected_hazard = 0
        0       // expected_data = 0 (no forwarding)
    );
}

// Test 5: Write to x0 - Should not forward
// Scenario: add x0, x1, x2 (in MEM, dest_m=0)
//           add x3, x0, x4 (in EX, needs x0)
// Expected: forward=0, hazard=0 (x0 is always 0, no forwarding needed)
TEST_F(HazardUnitTest, DataHazard_WriteToX0) {
    testHazard(
        0,      // execute_reg = x0
        1,      // valid_e = 1
        1,      // valid_m = 1
        0,      // load_m = 0
        0,      // valid_w = 0
        0,      // dest_m = x0
        0,      // dest_w = 0
        0xFFFF, // data_m (irrelevant)
        0,      // data_w
        0,      // expected_forward = 0 (x0 always 0)
        0,      // expected_hazard = 0
        0       // expected_data = 0
    );
}

// Test 6: MEM stage has priority over WB
// Scenario: add x4, x5, x6 (in WB, dest_w=4)
//           sub x4, x7, x8 (in MEM, dest_m=4)
//           and x9, x4, x10 (in EX, needs x4)
// Expected: Forward from MEM (more recent), not WB
TEST_F(HazardUnitTest, DataHazard_MEMPriorityOverWB) {
    testHazard(
        4,      // execute_reg = x4
        1,      // valid_e = 1
        1,      // valid_m = 1 (MEM has x4)
        0,      // load_m = 0
        1,      // valid_w = 1 (WB also has x4)
        4,      // dest_m = x4
        4,      // dest_w = x4
        0xAAAA, // data_m = newer value (MEM stage)
        0xBBBB, // data_w = older value (WB stage)
        1,      // expected_forward = 1
        0,      // expected_hazard = 0
        0xAAAA  // expected_data = MEM data (priority)
    );
}

// ============================================================================
// EDGE CASE TESTS (Still data hazards, but corner cases)
// ============================================================================

// Test 7: Valid_E = 0 - No instruction in EX stage
// Scenario: Pipeline bubble or flushed instruction in EX
// Expected: forward=0, hazard=0 (nothing to forward to)
TEST_F(HazardUnitTest, EdgeCase_NoInstructionInEX) {
    testHazard(
        5,      // execute_reg = x5
        0,      // valid_e = 0 (NO instruction in EX)
        1,      // valid_m = 1
        0,      // load_m = 0
        1,      // valid_w = 1
        5,      // dest_m = x5
        5,      // dest_w = x5
        0x1234, // data_m
        0x5678, // data_w
        0,      // expected_forward = 0 (no valid instruction)
        0,      // expected_hazard = 0
        0       // expected_data = 0
    );
}

// Test 8: Both MEM and WB invalid
// Scenario: Pipeline just started, no data in MEM or WB
// Expected: forward=0, hazard=0
TEST_F(HazardUnitTest, EdgeCase_EmptyPipeline) {
    testHazard(
        10,     // execute_reg = x10
        1,      // valid_e = 1
        0,      // valid_m = 0 (no instruction)
        0,      // load_m = 0
        0,      // valid_w = 0 (no instruction)
        10,     // dest_m = x10 (irrelevant, invalid)
        10,     // dest_w = x10 (irrelevant, invalid)
        0x9999, // data_m
        0x8888, // data_w
        0,      // expected_forward = 0
        0,      // expected_hazard = 0
        0       // expected_data = 0
    );
}

// Test 9: Cascading dependencies
// Scenario: Multiple instructions depend on same register
//           add x6, x7, x8 (WB, dest_w=6)
//           sub x9, x6, x10 (EX, needs x6)
// Expected: Forward from WB
TEST_F(HazardUnitTest, EdgeCase_CascadingDependencies) {
    testHazard(
        6,      // execute_reg = x6
        1,      // valid_e = 1
        0,      // valid_m = 0
        0,      // load_m = 0
        1,      // valid_w = 1
        7,      // dest_m = x7 (different)
        6,      // dest_w = x6
        0x0000, // data_m
        0xDEAD, // data_w
        1,      // expected_forward = 1
        0,      // expected_hazard = 0
        0xDEAD  // expected_data
    );
}


int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

