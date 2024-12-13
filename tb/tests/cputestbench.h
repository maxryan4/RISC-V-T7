#include "testbench.h"

class CpuTestbench : public Testbench
{

protected:
    void initializeInputs(const std::string& file_name) override {
        top->clk = 1; // Initialize clock
        top->rst = 0; // Initialize reset

        // string for the waveform file
        std::string filepath = "tests/waveforms/" + file_name + ".vcd";

        tfp->open(filepath.c_str());
    };
};
