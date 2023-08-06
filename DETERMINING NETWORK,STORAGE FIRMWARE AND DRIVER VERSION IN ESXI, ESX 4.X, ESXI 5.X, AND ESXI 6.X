Note: In ESXi 5.x, the swfw.sh command is supplied with the vm-support support bundle collection tool. The swfw.sh command can be used to identify the firmware and driver versions of hardware connected to the host. To run the command, use this path:

# /usr/lib/vmware/vm-support/bin/swfw.sh


Obtaining Host Bus adapter driver and firmware information
To determine the driver and firmware version of a Host Bus Adapter:
To determine the firmware version of a Host Bus Adapter, see Identifying the firmware of a Qlogic or Emulex FC HBA (1002413).
To obtain the driver version of a Host Bus Adapter on an ESXi/ESX host:

Open a console to the ESXi/ESX host. For more information, see Unable to connect to an ESX host using Secure Shell (SSH) (1003807) or Using Tech Support Mode in ESXi 4.1 and ESXi 5.x (1017910).
Run this command to obtain the driver type that the Host Bus Adapter is currently using:

# esxcfg-scsidevs -a

You see output similar to:

vmhba0 ata_piix link-n/a ide.vmhba0 (0:7.1) Intel Corporation Virtual Machine Chipset
vmhba1 mptspi link-n/a pscsi.vmhba1 (0:16.0) LSI Logic / Symbios Logic LSI Logic Parallel SCSI Controller
vmhba32 ata_piix link-n/a ide.vmhba32 (0:7.1) Intel Corporation Virtual Machine Chipset

Note: The second column shows the driver that is configured for the HBA.

Run this command to view the driver version in use:

# vmkload_mod -s HBADriver |grep Version

For example, run this command to check the mptspi driver:

# vmkload_mod -s mptspi |grep Version

Version: Version 4.00.37.00.30vmw, Build: 721907, Interface: 9.0, Built on: May 18 2012

In this example, the driver version is 4.00.37.00.30vmw.

To obtain the driver version for all HBAs in the system with a single command, use:

# for a in $(esxcfg-scsidevs -a |awk '{print $2}') ;do vmkload_mod -s $a |grep -i version ;done

To determine the recommended driver for the card, we must obtain the Vendor ID (VID), Device ID (DID), Sub-Vendor ID (SVID), and Sub-Device ID (SDID) using the vmkchdev command:

# vmkchdev -l |grep vmhba1

000:16.0 1000:0030 15ad:1976 vmkernel vmhba1

In this example, the values are:

VID = 1000
DID = 0030
SVID = 15ad
SDID = 1976

To obtain vendor information for all HBAs in the system using a single command:

# for a in $(esxcfg-scsidevs -a |awk '{print $1}') ;do vmkchdev -l |grep $a ;done

Search the VMware Compatibility Guide for the Vendor ID (VID), Device ID (DID), Sub-Vendor ID (SVID), and Sub-Device ID (SDID). In some cases, you may need to do a text search to narrow down the particular card.

Note: You can check the ESXi/ESX host version with the command:

# vmware -v
Obtaining Network card driver and firmware information

To determine the version information for a physical network interface card in vSphere ESXi/ESX 4.x and 5.x:

Open a console to the ESXi/ESX host. For more information, see Unable to connect to an ESX host using Secure Shell (SSH) (1003807) or Using Tech Support Mode in ESXi 4.1 and ESXi 5.x (1017910).
Obtain a list of network interface cards and names.

In ESXi/ESX 4.x, run this command:

# esxcfg-nics -l

For example:

# esxcfg-nics -l
Name PCI Driver Link Speed Duplex MAC Address
vmnic0 00:02:04.00 ACME Up 1000Mbps Full 01:23:45:67:89:AB
vmnic1 00:02:05.00 ACME Up 1000Mbps Full 01:23:45:67:78:AC

In ESXi 5.x, run this command:

# esxcli network nic list

Run the ethtool -i command to display available information for one of the network interfaces, specifying its name from step 2:

# ethtool -i VMNic_name

For example:

# ethtool -i vmnic0

driver: ACME
version: 1.2.3a-1vmw
firmware-version: 7.8.9
bus-info: 0000:02:04.00

To obtain information from # ethtool -i for all network adapters at once, you can run this command:

# for a in $(esxcfg-nics -l|awk '{print $1}'|grep [0-9]) ;do ethtool -i $a;done

In ESXi 5.x, this command can also be used:

# esxcli network nic get -n vmnic#

Note: If the network card is using a native driver (ESXi 5.5 and later), the ethtool command is not compatible, you must use the esxcli network command set to acquire network adapter information.
To determine the recommended driver for the card, we must obtain the Vendor ID (VID), Device ID (DID), Sub-Vendor ID (SVID), and Sub-Device ID (SDID) using the vmkchdev command:

# vmkchdev -l |grep vmnic0

002:01.0 8086:100f 15ad:0750 vmkernel vmnic0

In this example, the values are:

VID = 8086
DID = 100f
SVID = 15ad
SDID = 0750

Run this command to obtain vendor information for all NICs in the system using:

# for a in $(esxcfg-nics -l |awk '{print $1}' |grep [0-9]) ;do vmkchdev -l |grep $a ;done

You can now search the VMware Compatibility Guide for the Vendor ID (VID), Device ID (DID), Sub-Vendor ID (SVID), and Sub-Device ID (SDID). In some cases, you may need to do a text search to narrow down the particular card.

Note: Check the ESXi/ESX host version by running this command:
# vmware -v

From both the ESXi/ESX version and the network type, you then know the version of the driver to use. Driver updates are available on the VMware downloads page. 

Additional Information

This script information is only for ESXi 5.x.
Run this command in ESXi 5.x to obtain the driver version for all HBAs in the system:

esxcli storage core adapter list|awk '{print $1}'|grep [0-9]|while read a;do vmkload_mod -s $a|grep -i version;done
Run this command in ESXi 5.x to obtain vendor information for all HBAs in the system:

esxcli storage core adapter list|awk '{print $1}'|grep [0-9]|while read a;do vmkchdev -l |grep $a ;done
Run this command in ESXi 5.x to obtain information from ethtool -i for all network adapters:

esxcli network nic list | awk '{print $1}'|grep [0-9]|while read a;do ethtool -i $a;done
Run this command in ESXi 5.x to obtain vendor information for all NICs in the system:

esxcli network nic list | awk '{print $1}'|grep [0-9]|while read a;do vmkchdev -l|grep $a;done
Run these commands to see the driver VIBs (vSphere Installation Bundle) actually installed on the host:
esxcli software vib list can be used to check the installed VIBs
esxcli software vib list | grep xxx will list a specific driver xxx
