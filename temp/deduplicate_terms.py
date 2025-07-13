#!/usr/bin/env python3
import json

# Read the JSON file
with open('/mnt/c/Codes/office101/office101_app/assets/data/terms.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# List of term_ids to remove (the weaker definitions)
terms_to_remove = [
    "approval_001",  # 상신 - keeping approval_008
    "approval_002",  # 재가 - keeping approval_010  
    "approval_003",  # 결재 - keeping approval_007
    "it_045",        # 버그 - keeping it_002
    "hr_070",        # R&R - keeping hr_005 (identical)
    "it_034",        # 마일스톤 - keeping business_008
    "it_059",        # CTA - keeping marketing_033
    "marketing_075", # 포지셔닝 - keeping marketing_038
    "marketing_050", # 리드 - keeping marketing_060
]

# Filter out duplicate terms
original_count = len(data['terms'])
data['terms'] = [term for term in data['terms'] if term['term_id'] not in terms_to_remove]
new_count = len(data['terms'])

print(f"Removed {original_count - new_count} duplicate terms")
print(f"Original count: {original_count}")
print(f"New count: {new_count}")

# Write the cleaned data back
with open('/mnt/c/Codes/office101/office101_app/assets/data/terms.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Deduplication complete!")