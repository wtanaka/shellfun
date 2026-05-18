#!/bin/sh
# Copyright (C) 2025 Wesley Tanaka
# Simplified installer for Gemini CLI settings.
# Only installs if the destination file does not already exist.

DEST_DIR="$HOME/.gemini"
DEST="$DEST_DIR/settings.json"
SOURCE="gemini-settings.json"

if [ ! -e "$DEST" ]; then
    if [ ! -d "$DEST_DIR" ]; then
        mkdir -p "$DEST_DIR"
    fi
    if [ -f "$SOURCE" ]; then
        cp "$SOURCE" "$DEST"
    fi
fi