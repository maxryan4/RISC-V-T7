#include "testbench.h"
#include <cstdlib>

#define CYCLES 10000

unsigned int ticks = 0;

class CpuTestbench : public Testbench
{

protected:
    void initializeInputs(const std::string& file_name) override {
        top->clk = 1; // Initialize clock
        top->rst = 0; // Initialize reset

        std::string filepath = "tests/waveforms/" + file_name + ".vcd";

        tfp->open(filepath.c_str());
    };
};

TEST_F(CpuTestbench, BaseProgramTest)
{
  initializeInputs("program");
  // method which compiles an asm file and stores the result in tests directory
    compile("asm/singlecycle/program.S");

    bool success = false;
  // test is a method which runs the cpu for a certain number of clock cycles and stops when a0 = first argument (254)
  // every asm file is programmed in such a way that a0 = 254 only when the code works exactly as expected.

    success = test(254, CYCLES); 

    if (success)
    {
      SUCCEED();
    } else
    {
        FAIL() << "Counter did not reach 254";
    }
}

TEST_F(CpuTestbench, MulTest)
{
    initializeInputs("multest");
    compile("asm/singlecycle/multest.S");

    bool success = false;
    success = test(3, CYCLES); 

    if (success)
    {
      SUCCEED();
    }
    else
    { 
      FAIL() << "2 tests were not passed during byte loading tests.";
}
}

TEST_F(CpuTestbench, BranchProgramTest)
{
    initializeInputs("branchtest");
    compile("asm/singlecycle/branchtest.S");

    bool success = false;
    success = test(6, CYCLES); 

    if (success)
    {
      SUCCEED();
    } 
    else
    { 
      FAIL() << "6 tests were not passed during branching.";
    }
}

TEST_F(CpuTestbench, ArithmeticTest)
{
    initializeInputs("arithmetictest");
    compile("asm/singlecycle/arithmetictest.S");

    bool success = false;
    success = test(5, CYCLES); 

    if (success)
    {
      SUCCEED();
    } 
    else
    { 
      FAIL() << "5 tests were not passed during arithmetic tests.";
    }
}



TEST_F(CpuTestbench, LoadingAndJumpingTest)
{
    initializeInputs("loadingandjump");
    compile("asm/singlecycle/loadingandjump.S");

    bool success = false;
    success = test(4, CYCLES); 

    if (success)
    {
      SUCCEED();
    } 
    else
    { 
      FAIL() << "4 tests were not passed during loading and jump tests.";
    }
}



TEST_F(CpuTestbench, ShiftTest)
{
    initializeInputs("shifttest");
    compile("asm/singlecycle/shifttest.S");

    bool success = false;
    success = test(5, CYCLES); 

    if (success)
    {
      SUCCEED();
    } 
    else
    { 
      FAIL() << "5 tests were not passed during logical shifts.";
    }
}

TEST_F(CpuTestbench, ImmediateTesting)
{
    initializeInputs("immediatetest");
    compile("asm/singlecycle/immediatetest.S");

    bool success = false;
    success = test(9, CYCLES); 

    if (success)
    {
      SUCCEED();
    } 
    else
    { 
      FAIL() << "9 tests were not passed during immediate testing";
    }
}
TEST_F(CpuTestbench, LoadByteTesting)
{
    initializeInputs("loadbytetest");
    compile("asm/singlecycle/loadbytetest.S");

    bool success = false;
    success = test(4, CYCLES); 

    if (success)
    {
      SUCCEED();
    } 
    else
    { 
      FAIL() << "4 tests were not passed during byte loading tests.";
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
