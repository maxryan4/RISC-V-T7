#include "Vdut.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "vbuddy.cpp"
#include "cputestbench.h"
#include <cstdlib>


#define MAX_SIM_CYC 1000000

// instruction testing
TEST_F(CpuTestbench, VbuddyF1)
{
  initializeInputs("vbuddyf1");
  // method which compiles an asm file and stores the result in tests directory
  compile("asm/other/F1.S");

  //init Vbuddy
  if (vbdOpen() != 1) FAIL();
  vbdHeader("F1 Lights");
  vbdSetMode(1); // One-shot mode
  vbdBar(0); // reset lights

  int simcyc;
  int tick;
  // simulation loop
  for (simcyc = 0; simcyc < MAX_SIM_CYC; simcyc++) {
      
      runSimulation(1);

      
      vbdCycle(simcyc);

      vbdBar(top->a0 & 0xFF);
      vbdHex(3,(int(top->a0)>>8)&0xF);
      vbdHex(2,(int(top->a0)>>4)&0xF);
      vbdHex(1,int(top->a0)&0xF);
      

      // Simulation end condition
      if (Verilated::gotFinish()) {
        vbdClose();
        exit(0);
      }
      
  }
  
  vbdClose();
  exit(0);
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}      
