import pandas as pd
import sys

def read_gff(gff_path):
    columns = ['seqname', 'source', 'feature', 'start', 'end', 'score', 'strand', 'frame', 'attributes']
    gff_df = pd.read_csv(gff_path, sep='\t', comment='#', names=columns)
    genes_df = gff_df[gff_df['feature'] == 'gene']
    return genes_df

def read_bed(bed_path):
    columns = ['chrom', 'start', 'end', 'name']
    bed_df = pd.read_csv(bed_path, sep='\t', names=columns)
    return bed_df

def extract_genes_from_regions(gff_df, bed_df):
    extracted_genes = []
    for index, row in bed_df.iterrows():
        region_genes = gff_df[(gff_df['seqname'] == row['chrom']) & (gff_df['start'] <= row['end']) & (gff_df['end'] >= row['start'])]
        extracted_genes.append(region_genes)
    return pd.concat(extracted_genes) if extracted_genes else pd.DataFrame()

def main(gff_path, bed_path, output_path):
    gff_df = read_gff(gff_path)
    bed_df = read_bed(bed_path)
    genes = extract_genes_from_regions(gff_df, bed_df)
    print("Extracted Genes:")
    print(genes)
    genes.to_csv(output_path, index=False, sep='\t')

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <gff_path> <bed_path> <output_path>")
    else:
        gff_path = sys.argv[1]
        bed_path = sys.argv[2]
        output_path = sys.argv[3]
        main(gff_path, bed_path, output_path)
