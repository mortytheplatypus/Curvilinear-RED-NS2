#!/bin/bash

echo -e "\n------------- wireless.sh: starting -------------\n"

tcl_file="wireless.tcl"
output_file="wireless.csv"

isCLRED=$1
echo "isCLRED = $isCLRED" >> $output_file

# defining baseline parameters
baseline_area_side=500
baseline_nodes=40
baseline_flows=20
baseline_pktspersec=200

echo "" >> $output_file
echo "" >> $output_file
echo "Area, Throughput, Average Delay, Delivery Ratio, Drop Ratio, Energy Consumed" >> $output_file

echo -e "------------- varying area size -------------\n"
for((i=0; i<5; i++)); do
    area_side=`expr 250 + $i \* 250`
    echo -n "$area_side, " >> $output_file

    echo -e "running with $area_side $baseline_nodes $baseline_flows $baseline_pktspersec\n"
    ns $tcl_file $area_side $baseline_nodes $baseline_flows $baseline_pktspersec $isCLRED
    echo -e "\nparser.awk: running\n"
    awk -f wireless.awk trace.tr
done

echo "" >> $output_file
echo "" >> $output_file
echo "#Nodes, Throughput, Average Delay, Delivery Ratio, Drop Ratio, Energy Consumed" >> $output_file

echo -e "---------- varying number of nodes ----------\n"
for((i=0; i<5; i++)); do
    nodes=`expr 20 + $i \* 20`
    echo -n "$nodes, " >> $output_file

    echo -e "running with $baseline_area_side $nodes $baseline_flows $baseline_pktspersec\n"
    ns $tcl_file $baseline_area_side $nodes $baseline_flows $baseline_pktspersec $isCLRED
    echo -e "\nparser.awk: running\n"
    awk -f wireless.awk trace.tr
done


echo "" >> $output_file
echo "" >> $output_file
echo "#Flows, Throughput, Average Delay, Delivery Ratio, Drop Ratio, Energy Consumed" >> $output_file

echo -e "---------- varying number of flows ----------\n"
for((i=0; i<5; i++)); do
    flows=`expr 10 + $i \* 10`
    echo -n "$flows, " >> $output_file

    echo -e "running with $baseline_area_side $baseline_nodes $flows $baseline_pktspersec\n"
    ns $tcl_file $baseline_area_side $baseline_nodes $flows $baseline_pktspersec $isCLRED
    echo -e "\nparser.awk: running\n"
    awk -f wireless.awk trace.tr
done

echo "" >> $output_file
echo "" >> $output_file
echo "PktsPerSec, Throughput, Average Delay, Delivery Ratio, Drop Ratio, Energy Consumed" >> $output_file

echo -e "---------- varying number of packets per second ----------\n"
for((i=0; i<5; i++)); do
    pktspersec=`expr 100 + $i \* 100`
    echo -n "$pktspersec, " >> $output_file

    echo -e "running with $baseline_area_side $baseline_nodes $baseline_flows $pktspersec\n"
    ns $tcl_file $baseline_area_side $baseline_nodes $baseline_flows $pktspersec $isCLRED
    echo -e "\nparser.awk: running\n"
    awk -f wireless.awk trace.tr
done

echo -e "\n---------------- terminating ----------------\n"
# rm animation.nam trace.tr