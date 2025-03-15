import csv

input_file = "final_project/database_files/neo4j/papers.csv"
output_file = "cleaned_papers.csv"

with open(input_file, "r", encoding="utf-8") as infile, open(output_file, "w", encoding="utf-8", newline="") as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile)
    
    for row in reader:
        cleaned_row = [field.replace('"', '""') if '"' in field else field for field in row]  # Escape quotes properly
        writer.writerow(cleaned_row)

print("Fixed CSV saved as cleaned_papers.csv")