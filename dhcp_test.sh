#!/bin/bash

# Check if the user provided the number of leases to test
if [ -z "$1" ]; then
  echo "Usage: $0 <number_of_leases>"
  exit 1
fi

NUM_LEASES=$1

# Function to clean up created interfaces and DHCP clients
cleanup() {
  echo "Cleaning up..."
  for ((i=1; i<=NUM_LEASES; i++)); do
    sudo dhclient -r -pf /run/dhclient.mvlan$i.pid -lf /var/lib/dhcp/dhclient.mvlan$i.leases mvlan$i 2>/dev/null
    sudo ip link delete mvlan$i 2>/dev/null
  done
}

trap cleanup EXIT

# Get a list of available non-loopback network interfaces
AVAILABLE_IFACES=($(ip -o link show | awk -F': ' '{print $2}' | grep -v 'lo' | grep -v '@'))

echo "Available network interfaces:"
for idx in "${!AVAILABLE_IFACES[@]}"; do
  echo "[$((idx+1))] ${AVAILABLE_IFACES[$idx]}"
done

# Prompt user to select an interface
read -p "Select the base interface to use (1-${#AVAILABLE_IFACES[@]}): " IFACE_SELECTION

# Validate selection
if ! [[ "$IFACE_SELECTION" =~ ^[0-9]+$ ]] || [ "$IFACE_SELECTION" -lt 1 ] || [ "$IFACE_SELECTION" -gt "${#AVAILABLE_IFACES[@]}" ]; then
  echo "Invalid selection."
  exit 1
fi

BASE_IFACE="${AVAILABLE_IFACES[$((IFACE_SELECTION-1))]}"
echo "Using base interface: $BASE_IFACE"

# Install necessary dependencies
sudo apt-get update
sudo apt-get install -y iproute2 isc-dhcp-client

# Create report file
DATE=$(date +%Y-%m-%d_%H-%M-%S)
REPORT_FILE="output-DHCPtest-$DATE.txt"

echo "Starting DHCP lease test at $(date)" > "$REPORT_FILE"
echo "Number of interfaces to create: $NUM_LEASES" >> "$REPORT_FILE"
echo "Base interface: $BASE_IFACE" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Initialize counters
SUCCESS_COUNT=0
FAILURE_COUNT=0

# Create macvlan interfaces and request DHCP leases
for ((i=1; i<=NUM_LEASES; i++)); do
  IFACE="mvlan$i"
  echo "Creating interface $IFACE"

  # Create macvlan interface
  sudo ip link add $IFACE link $BASE_IFACE type macvlan mode bridge
  sudo ip link set $IFACE up

  # Request DHCP lease
  sudo dhclient -v -1 \
    -pf /run/dhclient.$IFACE.pid \
    -lf /var/lib/dhcp/dhclient.$IFACE.leases \
    $IFACE &

  sleep 0.2  # Slight delay to prevent overwhelming the DHCP server
done

# Wait for all DHCP requests to complete
wait

echo "DHCP lease testing completed."
echo "" >> "$REPORT_FILE"
echo "DHCP lease testing completed at $(date)" >> "$REPORT_FILE"

# List obtained IP addresses
echo "Obtained IP addresses:" | tee -a "$REPORT_FILE"
for ((i=1; i<=NUM_LEASES; i++)); do
  IFACE="mvlan$i"
  IP_ADDR=$(ip -4 addr show $IFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
  if [ -n "$IP_ADDR" ]; then
    echo "$IFACE: $IP_ADDR" | tee -a "$REPORT_FILE"
    SUCCESS_COUNT=$((SUCCESS_COUNT+1))
  else
    echo "$IFACE: No IP address assigned" | tee -a "$REPORT_FILE"
    FAILURE_COUNT=$((FAILURE_COUNT+1))
  fi
done

echo "" >> "$REPORT_FILE"
echo "Summary:" | tee -a "$REPORT_FILE"
echo "Number of interfaces created: $NUM_LEASES" | tee -a "$REPORT_FILE"
echo "Number of successful DHCP leases: $SUCCESS_COUNT" | tee -a "$REPORT_FILE"
echo "Number of failed DHCP leases: $FAILURE_COUNT" | tee -a "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "End of DHCP lease test report." >> "$REPORT_FILE"

echo "Report saved to $REPORT_FILE"
echo "Cleaning up..."
