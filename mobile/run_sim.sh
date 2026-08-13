#!/bin/bash
osascript -e 'tell application "Simulator" to activate'
sleep 1
# Tab to Email
osascript -e 'tell application "System Events" to keystroke tab'
sleep 0.5
osascript -e 'tell application "System Events" to keystroke "nuvi.kidz.test+phase1@gmail.com"'
sleep 0.5
# Tab to Password
osascript -e 'tell application "System Events" to keystroke tab'
sleep 0.5
osascript -e 'tell application "System Events" to keystroke "test1234"'
sleep 0.5
# Tab to Forgot Password
osascript -e 'tell application "System Events" to keystroke tab'
sleep 0.5
# Tab to Sign In
osascript -e 'tell application "System Events" to keystroke tab'
sleep 0.5
# Press Space
osascript -e 'tell application "System Events" to keystroke space'
