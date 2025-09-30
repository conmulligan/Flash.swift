#!/bin/bash -e

echo "Formatting..."

swift format format -i -p -r .

echo "Formatting complete!"
