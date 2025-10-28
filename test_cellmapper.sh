#!/bin/bash

# Test script for CellMapper API
# Usage: ./test_cellmapper.sh

echo "Testing CellMapper API with Moroccan coordinates..."
echo "MCC=604 (Morocco), MNC=2 (Maroc Telecom), RAT=LTE"
echo ""

# Test coordinates for Morocco (around Casablanca/Rabat area)
API_URL="https://api.cellmapper.net/v6/getTowers?MCC=604&MNC=2&RAT=LTE&boundsNELatitude=30.30&boundsNELongitude=-9.44&boundsSWLatitude=30.28&boundsSWLongitude=-9.46&filterFrequency=false&showOnlyMine=false&showUnverifiedOnly=false&showENDCOnly=false&cache=$(date +%s)000"

echo "API URL:"
echo "$API_URL"
echo ""

echo "Making request..."
if command -v curl >/dev/null 2>&1; then
    echo "Using curl:"
    curl -s -H "Accept: application/json" -H "User-Agent: TestScript/1.0" "$API_URL" | jq '.' 2>/dev/null || curl -s -H "Accept: application/json" -H "User-Agent: TestScript/1.0" "$API_URL"
elif command -v wget >/dev/null 2>&1; then
    echo "Using wget:"
    wget -q -O - --header="Accept: application/json" --header="User-Agent: TestScript/1.0" "$API_URL"
else
    echo "Neither curl nor wget available"
    exit 1
fi

echo ""
echo "Note: If you see 'NEED_RECAPTCHA' or rate limiting, wait a few minutes and try again."
echo "The CellMapper API has rate limits to prevent abuse."