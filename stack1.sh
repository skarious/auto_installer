#!/bin/bash

# Script codificado en Base64
ENCODED="IyEvYmluL2Jhc2gKCiMgVmVyaWZpY2EgcGFyYW1ldHJvcyBiw6FzaWNvcwppZiBbICIkIyIgLWx0IDMgXTsgdGhlbgogICAgZWNobyAiRXJyb3I6IE5lY2Vzc8OhcmlvIGluZm9ybWFyIG9zIHBhcmFtw6l0cm9zIGLDsXNpY29zIgogICAgZWNobyAiVXNvOiAkMCA8dHJhZWZpa19kb21haW4+IDxwb3J0YWluZXJfZG9tYWluPiA8ZW1haWw+IFt0aXBvX2luc3RhbGFjYW9dIgogICAgZXhpdCAxCmZpCgojIEFybWF6ZW5hIHBhcmFtdHJvcyBiw6FzaWNvcwpUUkFFRklLPSIkMSIKUE9SVEFJTkVSPT0iJDIiCkVNQUlMPSIkMyIKSU5TVEFMTF9UWVBFPSIkNCIKCiMgVmVyaWZpY2EgdGlwbyBkZSBpbnN0YWxhw6fDo28gZSBwYXJhbWV0cm9zIGFkaWNpb25haXMKLi4uIChjb250aW51YcOnw6NvIGRvIHNjcmlwdCBvcmlnaW5hbCkgLi4uCgojIERlY29kaWZpY2EgZSBleGVjdXRhCkRFQ09ERUQ9JChlY2hvICIkRU5DT0RFRCIgfCBiYXNlNjQgLWQpCmV2YWwgIiRERUNPREVEIgo="

# Decodifica y ejecuta el script
DECODED=$(echo "$ENCODED" | base64 -d)
eval "$DECODED"
