import sys
import pandas as pd
from scipy.stats import zscore

def calculate_zscore(input_file, output_file):
    # Load the data from the file
    data = pd.read_csv(input_file, sep=" ", header=None)
                
    # Ensure the data has at least four columns
    if data.shape[1] < 4:
        raise ValueError("Input file must contain at least four columns.")
                                    
    # Calculate z-score for the fourth column
    data['z_score'] = zscore(data.iloc[:, 3])
                                            
    # Save the data with the z-score to the output file
    data.to_csv(output_file, sep=' ', index=False, header=False)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_file> <output_file>")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        calculate_zscore(input_file, output_file)
