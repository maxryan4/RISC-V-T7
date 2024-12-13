#include "Vdut.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "vbuddy.cpp"
#include "cputestbench.h"
#include <cstdlib>


#define MAX_SIM_CYC 1000000

// instruction testing
TEST_F(CpuTestbench, VbuddyPDF)
{
  initializeInputs("vbuddypdf");
  // method which compiles an asm file and stores the result in tests directory
  compile("asm/other/pdf.S");
  // init Vbuddy
  if (vbdOpen() != 1) FAIL();
  vbdHeader("PDF plotting");

    int plotting_index = 0;
    int last_update = 0;
    int last_a0 = 0;
    int simcyc;
    int tick;
    // simulation loop
    for (simcyc = 0; simcyc < MAX_SIM_CYC; simcyc++) {
        runSimulation(1);
        
        if ((int)top->a0 > 0 && plotting_index == 0) {
          last_a0 = (int)top->a0;
          last_update = simcyc;
          plotting_index++;
        }
        
        
        if ((plotting_index > 0) && ((last_update + 5) == simcyc || (int)top->a0 != last_a0))
        {
          if ((last_update + 5) == simcyc)
          {
            std::cout << (int)top->a0 << std::endl;
            vbdPlot((int)top->a0, 0, 255);
            plotting_index++;  
          }
          last_a0 = (int)top->a0;
          last_update = simcyc;
        }

        if (plotting_index > 256) {
          break;
        }
        
        

                

        // Simulation end condition
        if (Verilated::gotFinish()) {
          vbdClose();
          exit(0);
        };
        
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
