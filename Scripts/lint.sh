#!/bin/bash -e

echo "Linting..."

swift-format lint -p -r ./Example ./Sources ./Tests

echo "Linting complete!"
