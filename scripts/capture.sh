#!/usr/bin/env bash
# =============================================================================
# TaskFlow — Emulator Capture Script
# Usage:
#   bash scripts/capture.sh screenshots        # capture all screens (PNG)
#   bash scripts/capture.sh screenshot <name>  # capture single screen (PNG)
#   bash scripts/capture.sh gif <name>         # record single flow (GIF)
#   bash scripts/capture.sh gif all            # record all flows (GIF)
#
# Requirements:
#   - Android emulator running (adb connected)
#   - ffmpeg installed (brew install ffmpeg)
#   - For GIF: ffmpeg with palette support
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCREENSHOTS_DIR="$PROJECT_ROOT/docs/screenshots"
GIFS_DIR="$PROJECT_ROOT/docs/gifs"
TMP_DIR="$PROJECT_ROOT/docs/.tmp"

mkdir -p "$SCREENSHOTS_DIR" "$GIFS_DIR" "$TMP_DIR"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
ADB="adb"
DEVICE=""

_detect_device() {
  DEVICE=$($ADB devices | awk 'NR>1 && $2=="device" {print $1; exit}')
  if [[ -z "$DEVICE" ]]; then
    echo "ERROR: No connected Android device/emulator found."
    echo "  Start an emulator or connect a device, then retry."
    exit 1
  fi
  echo "Using device: $DEVICE"
}

_screenshot() {
  local name="$1"
  local out="$SCREENSHOTS_DIR/${name}.png"
  echo "  Capturing $name..."
  $ADB -s "$DEVICE" shell screencap -p /sdcard/capture_tmp.png
  $ADB -s "$DEVICE" pull /sdcard/capture_tmp.png "$out" > /dev/null 2>&1
  $ADB -s "$DEVICE" shell rm /sdcard/capture_tmp.png
  echo "  Saved: docs/screenshots/${name}.png"
}

_wait() {
  sleep "${1:-1.5}"
}

_check_ffmpeg() {
  if ! command -v ffmpeg &>/dev/null; then
    echo "ERROR: ffmpeg not found. Install with: brew install ffmpeg"
    exit 1
  fi
}

# Convert raw MP4 screenrecord to GIF via ffmpeg palette trick
_mp4_to_gif() {
  local mp4="$1"
  local gif="$2"
  local palette="$TMP_DIR/palette.png"
  echo "  Converting to GIF..."
  ffmpeg -y -i "$mp4" -vf "fps=15,scale=320:-1:flags=lanczos,palettegen" "$palette" -loglevel error
  ffmpeg -y -i "$mp4" -i "$palette" \
    -filter_complex "fps=15,scale=320:-1:flags=lanczos[x];[x][1:v]paletteuse" \
    "$gif" -loglevel error
  rm -f "$palette" "$mp4"
  echo "  Saved: ${gif#$PROJECT_ROOT/}"
}

_start_record() {
  local mp4="$1"
  # screenrecord max 3 minutes; we kill it manually
  $ADB -s "$DEVICE" shell screenrecord --bit-rate 4000000 /sdcard/rec_tmp.mp4 &
  echo $!  # return PID
}

_stop_record() {
  local bg_pid="$1"
  local mp4="$2"
  # stop adb screenrecord on device
  $ADB -s "$DEVICE" shell pkill -l SIGINT screenrecord 2>/dev/null || true
  wait "$bg_pid" 2>/dev/null || true
  sleep 1
  $ADB -s "$DEVICE" pull /sdcard/rec_tmp.mp4 "$mp4" > /dev/null 2>&1
  $ADB -s "$DEVICE" shell rm /sdcard/rec_tmp.mp4
}

# ---------------------------------------------------------------------------
# Screenshot: all screens
# Navigate manually to each screen BEFORE running this, or use it after
# launching the app and navigating via adb input commands.
# ---------------------------------------------------------------------------
cmd_screenshots() {
  _detect_device
  echo ""
  echo "==> Screenshot mode"
  echo "    The script will pause between screens so you can navigate manually."
  echo "    Press ENTER after navigating to each screen."
  echo ""

  declare -A SCREENS=(
    ["01_splash"]="Splash screen"
    ["02_onboarding_1"]="Onboarding slide 1"
    ["03_onboarding_2"]="Onboarding slide 2"
    ["04_onboarding_3"]="Onboarding slide 3"
    ["05_home"]="Home page"
    ["06_schedule"]="Schedule page"
    ["07_new_task"]="New Task page"
    ["08_task_detail"]="Task Detail page"
    ["09_edit_task"]="Edit Task page"
    ["10_projects"]="Projects page"
    ["11_project_detail"]="Project Detail page"
    ["12_search"]="Search page"
    ["13_statistics"]="Statistics page"
    ["14_messages"]="Messages page"
    ["15_profile"]="Profile page"
    ["16_settings"]="Settings page"
  )

  for key in $(echo "${!SCREENS[@]}" | tr ' ' '\n' | sort); do
    echo "--> Navigate to: ${SCREENS[$key]}"
    read -r -p "    Press ENTER when ready... "
    _screenshot "$key"
  done

  echo ""
  echo "Done! All screenshots saved to docs/screenshots/"
}

# ---------------------------------------------------------------------------
# Screenshot: single
# ---------------------------------------------------------------------------
cmd_screenshot_single() {
  local name="${1:-screen}"
  _detect_device
  _screenshot "$name"
}

# ---------------------------------------------------------------------------
# GIF recordings — named flows
# ---------------------------------------------------------------------------

record_onboarding_flow() {
  echo "--> Recording: onboarding_flow"
  local mp4="$TMP_DIR/onboarding_flow.mp4"
  local gif="$GIFS_DIR/onboarding_flow.gif"
  echo "    Navigate to Splash screen on emulator, then press ENTER."
  read -r -p "    Press ENTER to start recording... "
  local pid
  pid=$(_start_record "$mp4")
  sleep 6  # watch splash + onboarding slides
  _stop_record "$pid" "$mp4"
  _mp4_to_gif "$mp4" "$gif"
}

record_new_task_flow() {
  echo "--> Recording: new_task_flow"
  local mp4="$TMP_DIR/new_task_flow.mp4"
  local gif="$GIFS_DIR/new_task_flow.gif"
  echo "    Navigate to Home page on emulator, then press ENTER."
  read -r -p "    Press ENTER to start recording... "
  local pid
  pid=$(_start_record "$mp4")
  sleep 8
  _stop_record "$pid" "$mp4"
  _mp4_to_gif "$mp4" "$gif"
}

record_task_detail_flow() {
  echo "--> Recording: task_detail_flow"
  local mp4="$TMP_DIR/task_detail_flow.mp4"
  local gif="$GIFS_DIR/task_detail_flow.gif"
  echo "    Navigate to Home or Schedule page, then press ENTER."
  read -r -p "    Press ENTER to start recording... "
  local pid
  pid=$(_start_record "$mp4")
  sleep 8
  _stop_record "$pid" "$mp4"
  _mp4_to_gif "$mp4" "$gif"
}

record_dark_mode_flow() {
  echo "--> Recording: dark_mode_flow"
  local mp4="$TMP_DIR/dark_mode_flow.mp4"
  local gif="$GIFS_DIR/dark_mode_flow.gif"
  echo "    Navigate to Settings page on emulator, then press ENTER."
  read -r -p "    Press ENTER to start recording... "
  local pid
  pid=$(_start_record "$mp4")
  sleep 6
  _stop_record "$pid" "$mp4"
  _mp4_to_gif "$mp4" "$gif"
}

record_project_detail_flow() {
  echo "--> Recording: project_detail_flow"
  local mp4="$TMP_DIR/project_detail_flow.mp4"
  local gif="$GIFS_DIR/project_detail_flow.gif"
  echo "    Navigate to Projects page on emulator, then press ENTER."
  read -r -p "    Press ENTER to start recording... "
  local pid
  pid=$(_start_record "$mp4")
  sleep 8
  _stop_record "$pid" "$mp4"
  _mp4_to_gif "$mp4" "$gif"
}

record_statistics_flow() {
  echo "--> Recording: statistics_flow"
  local mp4="$TMP_DIR/statistics_flow.mp4"
  local gif="$GIFS_DIR/statistics_flow.gif"
  echo "    Navigate to Statistics page on emulator, then press ENTER."
  read -r -p "    Press ENTER to start recording... "
  local pid
  pid=$(_start_record "$mp4")
  sleep 6
  _stop_record "$pid" "$mp4"
  _mp4_to_gif "$mp4" "$gif"
}

record_search_flow() {
  echo "--> Recording: search_flow"
  local mp4="$TMP_DIR/search_flow.mp4"
  local gif="$GIFS_DIR/search_flow.gif"
  echo "    Navigate to Search page on emulator, then press ENTER."
  read -r -p "    Press ENTER to start recording... "
  local pid
  pid=$(_start_record "$mp4")
  sleep 6
  _stop_record "$pid" "$mp4"
  _mp4_to_gif "$mp4" "$gif"
}

record_profile_edit_flow() {
  echo "--> Recording: profile_edit_flow"
  local mp4="$TMP_DIR/profile_edit_flow.mp4"
  local gif="$GIFS_DIR/profile_edit_flow.gif"
  echo "    Navigate to Profile page on emulator, then press ENTER."
  read -r -p "    Press ENTER to start recording... "
  local pid
  pid=$(_start_record "$mp4")
  sleep 8
  _stop_record "$pid" "$mp4"
  _mp4_to_gif "$mp4" "$gif"
}

cmd_gif() {
  local target="${1:-}"
  _detect_device
  _check_ffmpeg
  echo ""
  echo "==> GIF recording mode"
  echo "    Interact with the emulator during recording, then the script stops automatically."
  echo ""

  case "$target" in
    onboarding_flow)    record_onboarding_flow ;;
    new_task_flow)      record_new_task_flow ;;
    task_detail_flow)   record_task_detail_flow ;;
    dark_mode_flow)     record_dark_mode_flow ;;
    project_detail_flow) record_project_detail_flow ;;
    statistics_flow)    record_statistics_flow ;;
    search_flow)        record_search_flow ;;
    profile_edit_flow)  record_profile_edit_flow ;;
    all)
      record_onboarding_flow
      record_new_task_flow
      record_task_detail_flow
      record_dark_mode_flow
      record_project_detail_flow
      record_statistics_flow
      record_search_flow
      record_profile_edit_flow
      ;;
    *)
      echo "Available flows:"
      echo "  onboarding_flow"
      echo "  new_task_flow"
      echo "  task_detail_flow"
      echo "  dark_mode_flow"
      echo "  project_detail_flow"
      echo "  statistics_flow"
      echo "  search_flow"
      echo "  profile_edit_flow"
      echo "  all"
      exit 1
      ;;
  esac

  echo ""
  echo "Done! GIFs saved to docs/gifs/"
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
CMD="${1:-help}"

case "$CMD" in
  screenshots)   cmd_screenshots ;;
  screenshot)    cmd_screenshot_single "${2:-screen}" ;;
  gif)           cmd_gif "${2:-}" ;;
  help|--help|-h)
    echo "Usage:"
    echo "  bash scripts/capture.sh screenshots          # capture all screens (PNG)"
    echo "  bash scripts/capture.sh screenshot <name>    # capture single screen (PNG)"
    echo "  bash scripts/capture.sh gif <flow_name>      # record a flow as GIF"
    echo "  bash scripts/capture.sh gif all              # record all flows as GIF"
    echo ""
    echo "Requirements:"
    echo "  - Android emulator running (adb connected)"
    echo "  - ffmpeg: brew install ffmpeg"
    ;;
  *)
    echo "Unknown command: $CMD"
    echo "Run: bash scripts/capture.sh help"
    exit 1
    ;;
esac
