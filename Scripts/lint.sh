#!/bin/bash -e

echo "Linting..."

swift format lint -p -r .

echo "Linting complete!"
