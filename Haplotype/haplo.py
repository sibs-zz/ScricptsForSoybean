import pysam
import sys
from collections import defaultdict

vcf_path = sys.argv[1] 

vcf = pysam.VariantFile(vcf_path)

haplotypes = defaultdict(lambda: [])

valid_positions = set()

for record in vcf:
    if all(record.samples[sample]['GT'] is not None for sample in record.samples):
        valid_positions.add(record.pos)

vcf = pysam.VariantFile(vcf_path)  
for record in vcf:
    if record.pos in valid_positions:
        for sample in record.samples:
            gt = record.samples[sample]['GT']
            haplotypes[sample].append(gt)

haplotypes_str = {sample: str(gt_list) for sample, gt_list in haplotypes.items()}

unique_haplotypes = defaultdict(lambda: [])
for sample, haplotype in haplotypes_str.items():
    unique_haplotypes[haplotype].append(sample)

filtered_haplotypes = {k: v for k, v in unique_haplotypes.items() if len(v) >= 1}
sorted_haplotypes = sorted(filtered_haplotypes.items(), key=lambda x: len(x[1]), reverse=True)

print("Number of Unique Haplotypes with >= 1 Haplotypes:", len(sorted_haplotypes))
for idx, (haplotype, samples) in enumerate(sorted_haplotypes, start=1):
    print(f"Haplotype{idx}: {haplotype}, Count: {len(samples)}")
    for sample in samples:
        print(f"  Haplo{idx}: {sample}")

vcf.close()
