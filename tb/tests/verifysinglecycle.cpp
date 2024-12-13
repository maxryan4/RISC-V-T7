#include "cputestbench.h"
#include <cstdlib>

#define CYCLES 10000


// instruction testing
TEST_F(CpuTestbench, BaseProgramTest)
{
  initializeInputs("program");
  // method which compiles an asm file and stores the result in tests directory
  compile("asm/other/program.S");

  test(254, CYCLES);
  EXPECT_EQ(top->a0, 254);
}

TEST_F(CpuTestbench, BranchProgramTest)
{
    initializeInputs("branchtest");
    compile("asm/instruction_tests/branchtest.S");

    runSimulation(CYCLES);
    EXPECT_EQ(top->a0, 6);
}

TEST_F(CpuTestbench, ArithmeticTest)
{
    initializeInputs("arithmetictest");
    compile("asm/instruction_tests/arithmetictest.S");

    runSimulation(CYCLES);
    EXPECT_EQ(top->a0, 5);
}



TEST_F(CpuTestbench, LoadingAndJumpingTest)
{
    initializeInputs("loadingandjump");
    compile("asm/instruction_tests/loadingandjump.S");

    runSimulation(CYCLES);
    EXPECT_EQ(top->a0, 4);

}



TEST_F(CpuTestbench, ShiftTest)
{
    initializeInputs("shifttest");
    compile("asm/instruction_tests/shifttest.S");

    runSimulation(CYCLES);
    EXPECT_EQ(top->a0, 5);
}

TEST_F(CpuTestbench, ImmediateTesting)
{
    initializeInputs("immediatetest");
    compile("asm/instruction_tests/immediatetest.S");

    runSimulation(CYCLES);
    EXPECT_EQ(top->a0, 9);
}
TEST_F(CpuTestbench, LoadByteTesting)
{
    initializeInputs("loadbytetest");
    compile("asm/instruction_tests/loadbytetest.S");

    runSimulation(CYCLES);
    EXPECT_EQ(top->a0, 4);
}

// The 5 required tests
TEST_F(CpuTestbench, AddiBneTest)
{
    initializeInputs("addibnetest");
    compile("asm/required_tests/1_addi_bne.s");

    runSimulation(CYCLES);
    EXPECT_EQ(top->a0, 254);
}
TEST_F(CpuTestbench, LiAddTest)
{
    initializeInputs("liaddtest");
    compile("asm/required_tests/2_li_add.s");

    runSimulation(CYCLES);
    EXPECT_EQ(top->a0, 1000);
}
TEST_F(CpuTestbench, LbuSbTest)
{
    initializeInputs("lbusbtest");
    compile("asm/required_tests/3_lbu_sb.s");

    runSimulation(CYCLES);
    EXPECT_EQ(top->a0, 300);
}
TEST_F(CpuTestbench, JalrTest)
{
    initializeInputs("jalrtest");
    compile("asm/required_tests/4_jal_ret.s");

    runSimulation(CYCLES);
    EXPECT_EQ(top->a0, 53);
}


/* this test is not needed, as it is performed in pipelining
TEST_F(CpuTestbench, PdfTest)
{
    initializeInputs("pdfteset");
    compile("asm/required_tests/5_pdf.s");

    runSimulation(CYCLES);
    EXPECT_EQ(top->a0, 15363);
}
*/


int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}

