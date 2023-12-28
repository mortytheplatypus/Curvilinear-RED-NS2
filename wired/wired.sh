#!/bin/bash

echo -e "\n------------- wired.sh: starting -------------\n"

tcl_file="wired.tcl"
output_file="wired.csv"

isCLRED=$1
echo "isCLRED = $isCLRED" >> $output_file

# defining baseline parameters
baseline_nodes=40
baseline_flows=20
baseline_pktspersec=200

echo "" >> $output_file
echo "" >> $output_file
echo "#Nodes, Throughput, Average Delay, Delivery Ratio, Drop Ratio" >> $output_file

echo -e "---------- varying number of nodes ----------\n"
for((i=0; i<5; i++)); do
    nodes=`expr 20 + $i \* 20`
    echo -n "$nodes, " >> $output_file

    echo -e "running with $nodes $baseline_flows $baseline_pktspersec\n"
    ns $tcl_file $nodes $baseline_flows $baseline_pktspersec $isCLRED
    echo -e "\nparser.awk: running\n"
    awk -f wired.awk trace.tr
done


echo "" >> $output_file
echo "" >> $output_file
echo "#Flows, Throughput, Average Delay, Delivery Ratio, Drop Ratio" >> $output_file

echo -e "---------- varying number of flows ----------\n"
for((i=0; i<5; i++)); do
    flows=`expr 10 + $i \* 10`
    echo -n "$flows, " >> $output_file

    echo -e "running with $baseline_nodes $flows $baseline_pktspersec\n"
    ns $tcl_file $baseline_nodes $flows $baseline_pktspersec $isCLRED
    echo -e "\nparser.awk: running\n"
    awk -f wired.awk trace.tr
done

echo "" >> $output_file
echo "" >> $output_file
echo "#Nodes, Throughput, Average Delay, Delivery Ratio, Drop Ratio" >> $output_file

echo -e "---------- varying number of packets per second ----------\n"
for((i=0; i<5; i++)); do
    pktspersec=`expr 100 + $i \* 100`
    echo -n "$pktspersec, " >> $output_file

    echo -e "running with  $baseline_nodes $baseline_flows $pktspersec\n"
    ns $tcl_file $baseline_area_side $baseline_nodes $baseline_flows $pktspersec $isCLRED
    echo -e "\nparser.awk: running\n"
    awk -f wired.awk trace.tr
done

echo -e "\n---------------- terminating ----------------\n"
# rm animation.nam trace.tr