# DHCP Lease Testing Script

A Bash script to test the DHCP server capacity by simulating multiple DHCP lease requests from virtual network interfaces. This script creates multiple `macvlan` interfaces with unique MAC addresses, requests DHCP leases for each, and generates a formatted report with the results.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Report Output](#report-output)
- [Example](#example)
- [Notes and Considerations](#notes-and-considerations)
- [Clean up verification](#cleanup-verification)
- [License](#license)
- [Contributing](#contributing)
- [Contact](#contact)

## Features

- **Interactive Interface Selection:** Allows users to select the base network interface interactively.
- **Customizable Lease Count:** Users can specify the number of DHCP leases to test.
- **Formatted Report Generation:** Generates a detailed report with the number of successful and failed DHCP leases.
- **Automatic Cleanup:** Ensures all created interfaces and DHCP clients are terminated when the script exits.
- **Dependency Installation:** Installs required dependencies automatically if not already present.

## Requirements

- **Operating System:** Ubuntu Linux (or a similar Debian-based distribution)
- **Privileges:** Administrative privileges (script must be run with `sudo`)
- **Dependencies:**
  - `iproute2`
  - `isc-dhcp-client`

## Installation

Clone the Repository:

```bash
   git clone https://github.com/yourusername/dhcp-lease-test.git
```
Navigate to the Directory:

```bash
cd DHCP-Lease-Stress-Test
```
Make the Script Executable:

```bash
chmod +x dhcp_test.sh
```
Usage
Run the script with sudo and specify the number of DHCP leases you want to test:

```bash
sudo ./dhcp_test.sh <number_of_leases>
```
Example:

To test 50 DHCP leases:

```bash
sudo ./dhcp_test.sh 50
```
Interactive Interface Selection
Upon running the script, you will be prompted to select the base network interface:

```bash
Available network interfaces:
[1] enp0s25
[2] wlp4s0
Select the base interface to use (1-2):
```
Enter the number corresponding to the interface you wish to use.

## **Report Output**

The script generates a report file named output-DHCPtest-YYYY-MM-DD_HH-MM-SS.txt, where YYYY-MM-DD_HH-MM-SS represents the date and time when the script was run.

The report includes:

Start and completion times
Number of interfaces created
Base interface used
List of obtained IP addresses
Summary of successful and failed DHCP leases

## Example

Running the Script
```bash
sudo ./dhcp_test.sh 5
```
Sample Output

```bash

Available network interfaces:
[1] enp0s25
[2] wlp4s0
Select the base interface to use (1-2): 1
Using base interface: enp0s25
Creating interface mvlan1
Creating interface mvlan2
Creating interface mvlan3
Creating interface mvlan4
Creating interface mvlan5
DHCP lease testing completed.
Obtained IP addresses:
mvlan1: 192.168.50.216
mvlan2: 192.168.50.207
mvlan3: 192.168.50.190
mvlan4: 192.168.50.151
mvlan5: 192.168.50.174
Report saved to output-DHCPtest-2023-10-31_14-45-12.txt
Cleaning up...
```

Sample Report File (output-DHCPtest-XXXX-XX-XX_XX-XX-XX.txt)

```yaml
Starting DHCP lease test at Tue Oct 31 14:45:12 UTC 2024
Number of interfaces to create: 5
Base interface: enp0s25

DHCP lease testing completed at Tue Oct 31 14:46:20 UTC 2024
Obtained IP addresses:
mvlan1: 192.168.50.216
mvlan2: 192.168.50.207
mvlan3: 192.168.50.190
mvlan4: 192.168.50.151
mvlan5: 192.168.50.174

Summary:
Number of interfaces created: 5
Number of successful DHCP leases: 5
Number of failed DHCP leases: 0

End of DHCP lease test report.
```
## Notes and Considerations

**Permissions:**

The script must be run with sudo because it modifies network interfaces.
Ensure you have the necessary permissions and authorization to perform network testing in your environment.
Network Impact:

**Caution!**
Requesting a large number of DHCP leases can impact network resources.
Perform tests during maintenance windows or in isolated environments if possible.

**Interface Selection:**

Select a wired Ethernet interface for accurate testing.
Creating macvlan interfaces on wireless interfaces may not be supported or may behave unexpectedly.
DHCP Server Limitations:

The number of available IP addresses is limited by the DHCP server's configuration and subnet size.
If you receive "No IP address assigned" messages, the DHCP server may have reached its capacity.

## Cleanup Verification:

After the script completes, verify that no additional interfaces remain:
```bash
ip link show | grep mvlan
```
If any mvlan interfaces remain, delete them manually:
```bash
sudo ip link delete mvlanX
```
## License
This project is licensed under the MIT License.

## Disclaimer: Use this script responsibly and ensure compliance with your organization's policies and any applicable laws. Unauthorized network testing or resource exhaustion can lead to service disruptions and may be prohibited.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## Contact

For questions or suggestions, please use contact eduardo.ramos.garcia@outlook.com

