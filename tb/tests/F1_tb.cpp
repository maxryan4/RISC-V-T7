#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "vbuddy.cpp"

#define MAX_SIM_CYC 1000000

int main(int argc, char **argv, char **env) {
    int simcyc;
    int tick;

    Verilated::commandArgs(argc, argv);
    // init top Verilog instance
    Vtop *top = new Vtop;
    // init trace dump
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("top.vcd");

    // init Vbuddy
    if (vbdOpen() != 1) return (-1);
    vbdHeader("F1 Lights");
    vbdSetMode(1); // One-shot mode
    vbdBar(0); // reset lights

    // initialise simulation inputs
    top->clk = 1;
    top->rst = 0;

    // simulation loop
    for (simcyc = 0; simcyc < MAX_SIM_CYC; simcyc++) {
        
        // dump variables into VCD file and toggle clock
        for (tick = 0; tick < 2; tick++) {
            tfp->dump(2 * simcyc + tick);
            top->clk = !top->clk;
            top->eval();
        }
        
        vbdCycle(simcyc);

        vbdBar(top->a0 & 0xFF);
        vbdHex(3,(int(top->a0)>>8)&0xF);
        vbdHex(2,(int(top->a0)>>4)&0xF);
        vbdHex(1,int(top->a0)&0xF);

        // Simulation end condition
        if (Verilated::gotFinish()) exit(0);
        
    }

    vbdClose();
    tfp->close();
    exit(0);
}