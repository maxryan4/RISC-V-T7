#pragma once

#include "base_testbench.h"

unsigned int ticks = 0;
/**
 * Class only exists because top->clk is not always accessible in the testbench,
 * and will otherwise not compile.
 */
class Testbench : public BaseTestbench
{
public:
    // Runs the simulation for a clock cycle, evaluates the DUT, dumps waveform.
    void runSimulation(int cycles = 1)
    {
        for (int i = 0; i < cycles; i++)
        {
            for (int clk = 0; clk < 2; clk++)
            {
                top->eval();
#ifndef __APPLE__
                tfp->dump(2 * ticks + clk);
#endif
                top->clk = !top->clk;
            }
            ticks++;

            if (Verilated::gotFinish())
            {
                exit(0);
            }
        }
    }

    void compile(const std::string &program)
    {
        // Compile
        system(("./compile.sh " + program).c_str());
    }

    bool test(int expected_output, int max_cycles)
    {
        bool success = false;
        for (int i = 0; i < max_cycles; i++)
        {
            runSimulation(1);
            // checking if a0 is the expected output
            if (top->a0 == expected_output)
            {
                SUCCEED();
                success = true;
                break;
            }

            if (Verilated::gotFinish())
            {
                exit(0);
            }
        }
        return success;
    }
};
