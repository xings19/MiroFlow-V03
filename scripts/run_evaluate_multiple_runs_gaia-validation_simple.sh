#!/bin/bash

# SPDX-FileCopyrightText: 2025 MiromindAI
#
# SPDX-License-Identifier: Apache-2.0

# Configuration parameters
NUM_RUNS=3
CONFIG_NAME="agent_gaia-validation-gpt5"
BACKGROUND=true  # Set to true for background execution

export LOGGER_LEVEL="INFO"

RESULTS_DIR="logs/gaia-test/reproduce"

echo "Starting $NUM_RUNS runs of the evaluation..."
echo "Config: $CONFIG_NAME"
echo "Results will be saved in: $RESULTS_DIR"

mkdir -p "$RESULTS_DIR"

for i in $(seq 1 $NUM_RUNS); do
    echo "=========================================="
    echo "Launching experiment $i/$NUM_RUNS"
    echo "=========================================="
    
    RUN_ID="run_$i"
    
    if [ "$BACKGROUND" = true ]; then
        (
            uv run main.py common-benchmark \
                --config_file_name=$CONFIG_NAME \
                output_dir="$RESULTS_DIR/$RUN_ID" \
                > "$RESULTS_DIR/${RUN_ID}_output.log" 2>&1
            
            if [ $? -eq 0 ]; then
                echo "Run $i completed successfully"
            else
                echo "Run $i failed!"
            fi
        ) &
        
        sleep 2
    else
        uv run main.py common-benchmark \
            --config_file_name=$CONFIG_NAME \
            output_dir="$RESULTS_DIR/$RUN_ID" \
            > "$RESULTS_DIR/${RUN_ID}_output.log" 2>&1
        
        if [ $? -eq 0 ]; then
            echo "Run $i completed successfully"
        else
            echo "Run $i failed!"
        fi
    fi
done

if [ "$BACKGROUND" = true ]; then
    echo "All $NUM_RUNS runs have been launched in parallel"
    echo "Waiting for all runs to complete..."
    wait
fi

echo "=========================================="
echo "All $NUM_RUNS runs completed!"
echo "=========================================="

echo "Calculating average scores..."
uv run main.py avg-score "$RESULTS_DIR"

echo "=========================================="
echo "Multiple runs evaluation completed!"
echo "Check results in: $RESULTS_DIR"
echo "Check individual run logs: $RESULTS_DIR/run_*_output.log"
echo "=========================================="