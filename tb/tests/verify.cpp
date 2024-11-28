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

TEST_F(CpuTestbench, BaseProgramTest)
{
    compile("asm/program.S");

    bool success = false;
    success = test(254, CYCLES); 

    if (success)
    {
      SUCCEED() << "Counter reached 254";
    } else
    {
        FAIL() << "Counter did not reach 254";
    }
}

TEST_F(CpuTestbench, BranchProgramTest)
{
    compile("asm/branchtest.S");

    bool success = false;
    success = test(6, CYCLES); 

    if (success)
    {
      SUCCEED() << "All 6 tests were passed during branching.";
    } 
    else
    { 
      FAIL() << "6 tests were not passed during branching.";
    }
}

TEST_F(CpuTestbench, ArithmeticTest)
{
    compile("asm/arithmetictest.S");

    bool success = false;
    success = test(5, CYCLES); 

    if (success)
    {
      SUCCEED() << "All 5 tests were passed during arithmetic.";
    } 
    else
    { 
      FAIL() << "5 tests were not passed during arithmetic tests.";
    }
}

TEST_F(CpuTestbench, ShiftTest)
{
    compile("asm/shifttest.S");

    bool success = false;
    success = test(5, CYCLES); 

    if (success)
    {
      SUCCEED() << "All 5 tests were passed during logical shifts.";
    } 
    else
    { 
      FAIL() << "5 tests were not passed during logical shifts.";
    }
}

TEST_F(CpuTestbench, LoadingAndJumpingTest)
{
    compile("asm/loadingandjump.S");

    bool success = false;
    success = test(4, CYCLES); 

    if (success)
    {
      SUCCEED() << "All 5 tests were passed during loading and jump tests.";
    } 
    else
    { 
      FAIL() << "5 tests were not passed during during loading and jump tests.";
    }
}
// Note this is how we are going to test your CPU. Do not worry about this for
// now, as it requires a lot more instructions to function
/*
TEST_F(CpuTestbench, Return5Test)
{
    system("./compile.sh c/return_5.c");
    runSimulation(100);
    EXPECT_EQ(top->a0, 5);
}
*/

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
