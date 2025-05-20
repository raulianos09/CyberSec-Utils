#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <target>"
  echo "Example: $0 192.168.1.1"
  exit 1
fi

target="$1"

declare -a options=(
  "1) -sC             | Default NSE scripts"
  "2) -sV             | Version detection"
  "3) -p-             | Scan all ports"
  "4) -sS             | TCP SYN scan (stealthy and fast)"
  "5) -sT             | TCP Connect scan (less stealthy)"
  "6) -sU             | UDP scan"
  "7) -O              | OS detection"
  "8) -A              | Aggressive scan (OS, version, scripts, traceroute)"
  "9) -Pn             | No ping (skip host discovery)"
  "10) --script=vuln  | Run vulnerability scripts"
)

declare -a flags=(
  "-sC"
  "-sV"
  "-p-"
  "-sS"
  "-sT"
  "-sU"
  "-O"
  "-A"
  "-Pn"
  "--script=vuln"
)

echo "==============================="
echo "   Nmap Enumeration Menu"
echo " Target: $target"
echo "==============================="

for option in "${options[@]}"; do
  echo "$option"
done

echo ""
read -p "Enter option numbers (space-separated, e.g., 1 4 6): " input

read -ra selections <<< "$input"

nmap_params=""

for idx in "${selections[@]}"; do
  idx=$(echo "$idx" | xargs)
  if ! [[ "$idx" =~ ^[0-9]+$ ]]; then
    echo "Invalid input: $idx is not a number"
    exit 1
  fi
  num=$((idx - 1))
  if [[ $num -ge 0 && $num -lt ${#flags[@]} ]]; then
    nmap_params+=" ${flags[$num]}"
  else
    echo "Invalid option number: $idx"
    exit 1
  fi
done

# Default min-rate value
default_min_rate=1000

echo ""
read -p "Enter port(s) (e.g., 22,80 or 1-1000) or press Enter to skip: " ports

echo ""
read -p "Enter min-rate (default $default_min_rate): " min_rate_input
min_rate=${min_rate_input:-$default_min_rate}

echo ""

# Function to check affirmative input
is_affirmative() {
  local val=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  case "$val" in
    y|yes|true|1) return 0 ;;
    *) return 1 ;;
  esac
}

# Ask if output should be saved
read -p "Do you want to save output to a file? (y/n, yes/no, true/false, 1/0): " save_output

output_file=""
if is_affirmative "$save_output"; then
  read -p "Enter output filename: " output_file
  if [[ -z "$output_file" ]]; then
    echo "No filename entered, output will not be saved."
    output_file=""
  fi
fi

echo ""

# Build nmap command
cmd="nmap $nmap_params --min-rate $min_rate"

if [[ -n "$ports" ]]; then
  cmd+=" -p $ports"
fi

cmd+=" $target"

if [[ -n "$output_file" ]]; then
  cmd+=" -oN $output_file"
fi

echo "Running: $cmd"
eval $cmd
