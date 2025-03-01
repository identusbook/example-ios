#!/bin/bash

BASE_URL="http://localhost/cloud-agent/schema-registry/schemas"

# --- Logging ---
LOG_FILE="schema_creation.log"

# Function to log messages
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

RESPONSE=$(curl --silent --show-error --fail --location --request POST "$BASE_URL" \
  --header 'Content-Type: application/json' \
  --header 'accept: application/json' \
  --data-raw '{
  "name": "passport",
  "version": "1.0.0",
  "description": "Passport Schema",
  "type": "https://w3c-ccg.github.io/vc-json-schemas/schema/2.0/schema.json",
  "author": "did:prism:6753a3bbb99823e1d265cff4a0f95d1331b2050d86e9413bd54a5d1d01cb9c39",
  "tags": [
    "passport",
    "schema"
  ],
  "schema": {
    "$id": "https://identusbook.com/passport-1.0.0",
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "description": "Passport",
    "type": "object",
    "properties": {
      "name": {
        "type": "string"
      },
      "did": {
        "type": "string"
      },
      "dateOfIssuance": {
        "type": "string",
        "format": "date-time"
      },
      "passportNumber": {
        "type": "string"
      },
      "dob": {
        "type": "string",
        "format": "date-time"
      }
    },
    "required": [
      "name",
      "did",
      "dateOfIssuance",
      "passportNumber",
      "dob"
    ],
    "additionalProperties": true
  }
}')

# --- Error Handling ---
if [ $? -ne 0 ]; then
  log "Failed to create Schema. Check the server or request configuration."
  exit 1
else
  log "Schema creation successful."
  echo "Response: $RESPONSE" | tee -a $LOG_FILE
fi
