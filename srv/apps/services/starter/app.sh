#!/bin/bash

APP_SCRIPT="app.r"
APP_PORT=8000
HOST="127.0.0.1"  # or 0.0.0.0 if you want to expose it to the network

# Function to kill any process running on the specified port
function kill_existing_app {
    echo "Killing any process using port $APP_PORT..."
    fuser -k ${APP_PORT}/tcp 2>/dev/null || true
}

# Function to start the R app
function start_app {
    echo "sass ./src/css/home.scss ./src/css/home.css"
    echo "Starting app on http://$HOST:$APP_PORT..."
    Rscript "$APP_SCRIPT"
    echo "App started. Open the URL in your browser: http://$HOST:$APP_PORT"
}

kill_existing_app
start_app
