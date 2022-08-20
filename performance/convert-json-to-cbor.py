import cbor2, json
from pathlib import Path


with open("/home/thomas/thesis/monntpy-lab/performance/ingest-benchmark/ingest.json", "r") as fh:
    j = json.load(fh)
with open("/home/thomas/thesis/monntpy-lab/performance/ingest-benchmark/ingest.cbor", "wb") as cfh:
    cfh.write(cbor2.dumps(j))

