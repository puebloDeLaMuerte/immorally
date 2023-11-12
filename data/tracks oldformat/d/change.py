def process_text(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    output_lines = []
    i = 0

    while i < len(lines):
        line = lines[i].strip()
        if line == 'checkpoint':
            output_lines.append('type')
            i += 1
            number = lines[i].strip()
            if number == '-1':
                output_lines.append('0')
            else:
                output_lines.append('1')
                output_lines.append('typeData')
                output_lines.append(number)
        else:
            output_lines.append(line)
        i += 1

    return '\n'.join(output_lines)

# File paths
input_file_path = '/Users/pt/Documents/Processing/immorally/data/tracks oldformat/d/doubles.track'  # Replace with your input file path
output_file_path = '/Users/pt/Documents/Processing/immorally/data/tracks oldformat/d/doubles_o.track'  # Replace with your output file path

# Process and write to output file
processed_text = process_text(input_file_path)
with open(output_file_path, 'w') as file:
    file.write(processed_text)

print(f"Processed text written to {output_file_path}")