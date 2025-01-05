#!/bin/bash
# Compatible with Bash and Zsh

# --- Configuration ---
API_KEY="${API_KEY:-your-default-api-key}" # Replace with your default API key or set it as an environment variable.
BASE_URL="http://localhost/cloud-agent/did-registrar/dids"

# --- Logging ---
LOG_FILE="did_creation.log"

# Function to log messages
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# --- Curl Command ---
log "Starting DID creation request..."

RESPONSE=$(curl --silent --show-error --fail --location --request POST "$BASE_URL" \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --header "apikey: $API_KEY" \
  --data-raw '{
    "documentTemplate": {
      "publicKeys": [
        {
          "id": "auth-1",
          "purpose": "authentication"
        },
	{
          "id": "issue-1",
          "purpose": "assertionMethod"
        }
      ],
      "services": []
    }
  }') | jq

# --- Error Handling ---
if [ $? -ne 0 ]; then
  log "Failed to create DID. Check the server or request configuration."
  exit 1
else
  log "DID creation successful."
  echo "Response: $RESPONSE" | tee -a $LOG_FILE
fi
