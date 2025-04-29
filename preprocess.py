#!/bin/python

#import re
import math

# Define the file paths
input_file_path = "prefab-athinput.master_project"
output_file_path = "athinput.pp_master_project"

time = 6e4
outputdt = 10
spin = 0.998

th_nocool = 0.1

r_edge = 6.0
r_peak = 12.0


mass = 1.0 #per recommendation, we leave this at 1
horizon = mass * (1.0 + math.sqrt(1.0 - (spin/mass)**2))
actualtime = time * mass
actualdt = outputdt * mass
#ISCO is calculated in modified AthenaPP problem generator

# Define the replacements: exact matches
replacements = {
    "{MASS}": mass,
    "{HORIZON}": horizon,
    "{SPIN}": spin,
    "{TIME}": actualtime,
    "{O_DT}": actualdt,
    "{TH_NOCOOL}": th_nocool,
    "{R_EDGE}": r_edge,
    "{R_PEAK}": r_peak
}

def replace_exact_strings(input_path, output_path, replacements_dict):
    try:
        # Read the input file
        with open(input_path, 'r', encoding='utf-8') as file:
            content = file.read()

        # Replace exact matches
        for target, replacement in replacements_dict.items():
            content = content.replace(target, str(replacement))

        # Write the modified content to the output file
        with open(output_path, 'w', encoding='utf-8') as file:
            file.write(content)

        print(f"File processed successfully. Output saved to {output_path}")

    except FileNotFoundError:
        print(f"Error: The file {input_path} was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

# Run the function
replace_exact_strings(input_file_path, output_file_path, replacements)

