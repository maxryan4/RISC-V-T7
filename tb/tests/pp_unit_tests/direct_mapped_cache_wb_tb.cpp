#include "Vdut.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "gtest/gtest.h"
#include <memory>

// Test fixture for Write-Back Cache
class DirectCacheTest : public ::testing::Test {
protected:
    std::unique_ptr<Vdut> cache;
    vluint64_t sim_time = 0;

    void SetUp() override {
        cache = std::make_unique<Vdut>();
        // Initialize inputs
        cache->cpu_clock_i = 0;
        cache->cpu_addr_i = 0;
        cache->cpu_data_i = 0;
        cache->cpu_mem_ctrl_i = 0;
        cache->cpu_mem_write_i = 0;
        cache->cpu_valid_i = 0;
        cache->wb_stall_i = 0;
        cache->wb_ack_i = 0;
        cache->wb_dat_i = 0;
        cache->wb_err_i = 0;
    }
   void tick() {
        cache->cpu_clock_i = 1;
        cache->eval();
        sim_time++;
        cache->cpu_clock_i = 0;
        cache->eval();
        sim_time++;
    }

    void TearDown() override {
        cache->final();
    }


  void ack_memory(uint32_t data = 0) {
        cache->wb_ack_i = 1;
        cache->wb_dat_i = data;
        cache->eval();
        tick();
        cache->wb_ack_i = 0;
        cache->eval();
    }

};

// attempting to read data that isn't in cache
// expecting a FILL, checking that after the fill
// it can be read
TEST_F(DirectCacheTest, ReadHit) {
    // First, fill the cache line at set 0 with known data
    // Simulate a previous fill that put 0xDEADBEEF at set 0
    cache->cpu_addr_i = 0x000;  // Set 0, tag 0
    cache->cpu_valid_i = 1;
    cache->cpu_mem_write_i = 0;  // Read
    cache->eval();

    // Cache miss initially, will trigger FILL
    EXPECT_EQ(cache->cpu_en_o, 0) << "Should stall on cold miss";

    tick();
    // Simulate memory acknowledging fill
    ack_memory(5);

    // Now cache line is valid
    // Try reading the same address again - should HIT
    cache->cpu_addr_i = 0x000;
    cache->cpu_valid_i = 1;
    cache->cpu_mem_write_i = 0;
    cache->eval();

    EXPECT_EQ(cache->cpu_en_o, 1) << "Should NOT stall on hit";
    EXPECT_EQ(cache->cpu_data_o, 5) << "Should return cached data";
}



int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

