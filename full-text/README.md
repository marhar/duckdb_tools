# Full Text Demo

```
┌───────────────────┬──────────┬──────────────────────────────────────────────────┐
│       score       │   ref    │                search for 'whale'                │
│      double       │ varchar  │                     varchar                      │
├───────────────────┼──────────┼──────────────────────────────────────────────────┤
│   2.7248255618541 │ Eze32:2  │ Son of man, take up a lamentation for Pharaoh …  │
│ 3.839526928067141 │ Ge1:21   │ And God created great whales, and every living…  │
│ 3.839526928067141 │ Mat12:40 │ For as Jonas was three days and three nights i…  │
│ 6.497660955190547 │ Job7:12  │ Am I a sea, or a whale, that thou settest a wa…  │
└───────────────────┴──────────┴──────────────────────────────────────────────────┘
```

Two flavors of demo:
- full-text-demo.py
- full-text-demo.sql

Two equivalent programs to generate the csv and parquet files.
- generate-input.py
- generate-input.sh

Generate from kjv.txt:
- kjv-2col.csv
- kjv-2col.parquet
- kjv-4col.csv
- kjv-4col.parquet

