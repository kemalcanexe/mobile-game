#!/bin/bash
# Kullanım: SCENE=res://scenes/run.tscn SHOTS=1,3 OUT=/path/prefix [RUN=1] [COURSE=..] tools/shoot.sh
cd "$(dirname "$0")/.."
timeout ${TIMEOUT:-120} xvfb-run -a -s "-screen 0 1080x1920x24" godot --path . --rendering-driver opengl3 --resolution ${RES:-540x960} res://tools/shooter.tscn 2>&1 | grep -E "ERROR|SCRIPT|PERF" | grep -v -E "alsa|audio" | head -20
