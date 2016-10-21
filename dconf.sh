#!/bin/sh
# Copyright (C) 2016 Wesley Tanaka
if command -v dconf > /dev/null && [ -n "$DISPLAY" ]; then
  dconf write /com/canonical/indicator/datetime/locations "['UTC UTC', 'America/Los_Angeles San Francisco', 'America/New_York New York']"
  dconf write /com/canonical/indicator/datetime/show-date true
  dconf write /com/canonical/indicator/datetime/show-day true
  dconf write /com/canonical/indicator/datetime/show-locations true
  dconf write /com/canonical/indicator/datetime/show-seconds true
  dconf write /com/canonical/indicator/datetime/time-format "'24-hour'"
  # Prevent Super key from opening dash
  dconf write /org/compiz/profiles/unity/plugins/unityshell/show-launcher '"Disabled"'
  # Prevent Windows-Tab from focusing launcher
  dconf write /org/compiz/profiles/unity/plugins/unityshell/launcher-switcher-prev '"Disabled"'
  dconf write /org/compiz/profiles/unity/plugins/unityshell/launcher-switcher-forward '"Disabled"'
  # Switch drag window modifier to Super
  dconf write /org/gnome/desktop/wm/preferences/mouse-button-modifier '"<Super>"'
  # Sloppy mouse focus
  dconf write /org/gnome/desktop/wm/preferences/focus-mode '"sloppy"'
  # Use locally integrated menus
  dconf write /com/canonical/unity/integrated-menus true
fi
