#!/bin/bash


export PATH=/opt/riscv/bin:$PATH
# Usage: ./compile.sh <file.s>

# Default vars
SCRIPT_DIR=$(dirname "$(realpath "$0")")
output_file="tests/program1.hex"
touch "${output_file}"

# Handle terminal arguments
if [[ $# -eq 0 ]]; then
    echo "Usage: ./compile.sh <file.s>"
    exit 1
fi

input_file=$1
basename=$(basename "$input_file" | sed 's/\.[^.]*$//')
parent=$(dirname "$input_file")
file_extension="${input_file##*.}"

# Compile the C code if necessary.
if [ $file_extension == "c" ]; then
    # IMPORTANT: MUST NOT OPTIMIZE COMPILER! Or instructions could be lost!
    riscv64-unknown-elf-gcc -S -g -O0 -fno-builtin -static \
                            -march=rv32im -mabi=ilp32 \
                            -o "${basename}.s" $input_file \
                            -Wno-unused-result
    # To get test case 24 passing, you need to modify ^^^^
    input_file="${basename}.s"
fi

riscv64-unknown-elf-as -R -march=rv32im -mabi=ilp32 \
                        -o "a.out" "${input_file}"

# Remove the .s file if necessary
if [ $file_extension == "c" ]; then
    rm ${input_file}
fi

riscv64-unknown-elf-ld -melf32lriscv \
                        -e 0xBFC00000 \
                        -Ttext 0xBFC00000 \
                        -o "a.out.reloc" "a.out"

riscv64-unknown-elf-objcopy -O binary \
                            -j .text "a.out.reloc" "a.bin"

rm *dis 2>/dev/null

# This generates a disassembly file
# Memory in wrong place, but makes it easier to read (should be main = 0xbfc00000)
riscv64-unknown-elf-objdump -f -d --source -m riscv \
                            a.out.reloc > ${SCRIPT_DIR}/${basename}.dis

# Formats into a hex file
od -v -An -t x1 "a.bin" | tr -s '\n' | awk '{$1=$1};1' > "${output_file}"


final_file="tests/program.hex"
touch "${final_file}"
# Clear the output file before appending new data
> "${final_file}"


# Read the file line by line
while read -r line; do
    # Split the line into words and loop through them
    words=($line)
    for ((i = 0; i < ${#words[@]} - 3; i+=4)); do
        # Print the next 4 words
        echo "${words[i+3]}${words[i+2]}${words[i+1]}${words[i]}" >> "${final_file}"
    done

done < "${output_file}"



rm "a.out.reloc"
rm "a.out"
rm "a.bin"
rm "$output_file"