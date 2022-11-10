import cbor2, json, zlib
from pathlib import Path


with open("ingest.json", "r") as fh:
    j = json.load(fh)
with open("ingest.cbor", "wb") as cfh:
    cfh.write(cbor2.dumps(j))
with open("ingest_zlib.cbor", "wb") as czfh:
    czfh.write(zlib.compress(cbor2.dumps(j)))

