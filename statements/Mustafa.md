# Mustafa Idris


## Worked on

* [top.sv (single cycle)]
* [instruction tests]
* [pipeline tests]
* [verification]

## Creating [top.sv (single cycle)] file


I created the initial top.sv file, which succeeded in executing the [base program file].
To aid me with this task, I used the [single cycle CPU diagram]() that was provided in the lecture slides.
I made sure that all signal names matched the ones used in the diagram, or used in the modules outside of top.sv.
During my first tests of the program, I manually created a [program.hex]() file and filled it with the [program.S]() hex instructions.
Running this in the test bench that was provided during [lab 4]() allowed me to confirm that the top file was working correctly.





## Creating the [instruction tests]



Writing the assembly instruction tests consisted of 3 important sets of tests: the [initial tests](), which "worked", but were logically incorrect. The [second set of tests](), which verified all of the essential RV32I instructions for the single cycle cpu, and later the pipelined cpu. And the [final and full set of tests](), which tested the full list of instructions that our pipelined CPU was capable of.

### Initial tests

The idea was to create a file which consisted of multiple tests. Each assembly file tested a specific category of instructions, for example, [arithmetic.S] tested simple arithmetic instructions such as sub and add. Most tests where tested by incrementing a0 for every test that was passed. For example, 4 instructions were being tested, I must check for a0 being equal to 4 in the testbench.


All of the tests, to my surprise, passed on the first try when I ran the testbench shell script file. Only when I questioned this and asked for help I noticed that my initial set of tests, really weren't testing anything.

### corrected tests


If all of the tests pass, the program runs fine. But the only issue is that If no errors occured, a0 would still reach the expected value, since the program would always continue to the next label even if the branch to that label was not taken. To fix this, I simply had to add a fail condition. If a test fails, the program hangs. From this I was able to finally test the single cycle CPU against the full set of relevant instructions.

### final and full set of tests

As more instructions were added, more assembly files were added to this directory in order to test those instructions. Some programs such as multest.S did not expect an output based on number of tests passed, this test would instead perform an operation (10 * 5) and then expect the output of the operation (50). This directory is used both for single cycle and pipelined, since the instructions will work the same for both. The only difference is the number of clock cycles taken to execute the entire program.




## Creating pipeline tests


To ensure that the pipeline was working exactly as expected, more test cases were created specifically to check if the pipelining didn't fail during hazards, loading, storing and stalling. I created 2 tests for dependancy hazards, 3 for branch prediction and 2 for storing and loading.

### Dependancy hazards

This was the easiest assembly file to write and test, for [addtest_1.S](), I was checking if there would be an issue with performing arithmetic using a register that was altered in the previous clock cycle.

this, along with [addtest_2.S]() were the easiest to test, and worked as soon as the CPU had valid stalling.

### Branch prediction

The next task was to write assembly code that would be able to test the branching. The assembly program itself will only tests to see whether a branch is correctly taken, however it will not test for branch prediction itself. That can be done by tracing the waveform and seeing if the CPU was correctly predicting the branch and taking it early.

The best example of this is in [branchprediction_2.S](). You can see from the waveform below that the program incorrectly predicts a branch, but does not take that branch. This is proven by the final value of a0, which is exactly what was expected. The mispredicted branch is shown through PCSrc_e, which goes high alhough the branch is never fully taken.

[branch prediction waveform]()


## Creating [pipeline tests]



To ensure that the pipeline was working exactly as expected, more test cases were created specifically to check if the pipelining didn't fail during hazards, loading, storing and stalling. I created 2 tests for dependancy hazards, 3 for branch prediction and 2 for storing and loading.

### Dependancy hazards

This was the easiest assembly file to write and test, for [addtest_1.S](), I was checking if there would be an issue with performing arithmetic using a register that was altered in the previous clock cycle.


this, along with [addtest_2.S]() were the easiest to test, and worked as soon as the CPU had valid stalling.

### Branch prediction

The next task was to write assembly code that would be able to test the branching. The assembly program itself will only tests to see whether a branch is correctly taken, however it will not test for branch prediction itself. That can be done by tracing the waveform and seeing if the CPU was correctly predicting the branch and taking it early.

The best example of this is in [branchprediction_2.S](). You can see from the waveform below that the program incorrectly predicts a branch, but does not take that branch. This is proven by the final value of a0, which is exactly what was expected. The mispredicted branch is shown through PCSrc_e, which goes high alhough the branch is never fully taken.


### store and load hazard tests

The final set of tests is the load and store hazard tests. This is almost no different to [instruction_tests/loadbytetest.S](),instruction_tests, but it is useful as it helped expose some issues that would rise only in cases where store, load and add instructions were being used consecutively.

## Writing the verification files

Commit list-
* [initial verification format]()
* [separation of pipelined and single cycle]()
* [changing of format]()


To test the CPU using the assembly files, I initially modified the [verified.cpp file]() that was given to us in lab4. Later on, I then duplicated this file and had seperate files for single cycle and pipelined verification. This was important as the pipelined CPU went above and beyond the single cycle CPU. There were many instructions and programs that the pipelined CPU would support, but not supported within the single cycle CPU (such as [multest.S]()).

### Initial verification
Initially, the verification was done by running a program until a0 reaches the expected value, once this value was reached, the program would exit. This was especially good for programs such as [program.S]() where the program would restart if it wasn't terminated at the expected output.


### Separating of pipelined and single cycle CPU
Separating the pipelined and single cycle verification was key, as the pipelined required testing of a wider number of instructions and programs. It was also useful in debugging, for example if a program runs perfectly in the single cycle CPU, but does not run at all in the pipelined version, the issue is in the pipelined version. An example of a test that was only used in the pipelined version was [multest.S](), as mentioned above in the [instruction tests]() section.

### changing of format

The code in every test case was repeated, I also noticed that I could achieve the same goal in a much simpler way


The key difference is that the program is run for a certain number of clock cycles, if it is ran using test(), it may also stop early at the expected output. Otherwise, using runSimulation() for programs that hang when they are finished will also work perfectly fine. This signicantly improved the readability of my code, despite it doing almost the exact same thing.



## What I learned
I learnt the importance of teamwork.
I learnt the importance of readable code.
I learnt the importance of modularity in programming


## If I had more time

I would have loved to simulate it in qemu
