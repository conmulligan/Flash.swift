#!/bin/bash -e

echo "Formatting..."

swift format format -i -p -r ./Example ./Sources ./Tests

echo "Formatting complete!"
