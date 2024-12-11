#include "testbench.h"
#include <cstdlib>

#define CYCLES 10000

unsigned int ticks = 0;

class CpuTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 1;
        top->rst = 0;
    }
};

TEST_F(CpuTestbench, PipelineTest)
{
  // method which compiles an asm file and stores the result in tests directory
    compile("asm/pipelined/test.S");

    bool success = false;

    success = test(1, CYCLES); 

    if (success)
    {
      SUCCEED();
    } else
    {
        FAIL() << "Counter did not reach 1";
    }
}

TEST_F(CpuTestbench, PipelineHangTest)
{
  // method which compiles an asm file and stores the result in tests directory
    compile("asm/pipelined/hang.S");

    runSimulation(100);

    SUCCEED();
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
