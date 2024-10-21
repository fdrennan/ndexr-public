#!/bin/bash

# Original GIF file name
input_file="coolload.gif"

# Output optimized GIF file name
output_file="coolload_optimized.gif"

# Resize width (you can adjust this)
resize_width=200

# Optimize and resize the GIF
gifsicle --optimize=3 --colors 64 --resize-width ${resize_width} -O3 -o ${output_file} ${input_file}

# Display the result
echo "Original GIF size:"
ls -lh ${input_file}

echo "Optimized GIF size:"
ls -lh ${output_file}

echo "Optimization complete. Optimized GIF saved as ${output_file}"

