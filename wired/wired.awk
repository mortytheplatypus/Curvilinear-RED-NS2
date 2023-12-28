BEGIN {
    received_packets = 0;
    sent_packets = 0;
    dropped_packets = 0;
    total_delay = 0.0;
    received_bytes = 0;
    
    start_time = 1000000;
    end_time = 0;

	header = 40; # for tcp	

    output_file="output-wired.csv"
}

{
	strEvent = $1 ;	
	time_sec = $2 ;
	from = $3;
	to = $4;
	packet_type = $5;
	pcktSize = $6;
	flags = $7; 
    flagid = $8;
	source = $9; 
    dest = $10; # node.port -> actual src & dest
	seqNum = $11; 
    idPacket = $12;

	source = int(source);
	dest = int(dest);
	
	 if (packet_type=="tcp") {
		if (time_sec < start_time) start_time=time_sec;
		if (time_sec > end_time) end_time=time_sec;

		if (strEvent == "+" && from == source) {
			sent_packets += 1 ;	rSentTime[idPacket] = time_sec ;
		}

		if (strEvent == "r" && to == dest && received_time[idPacket] == 0.0) {
			received_packets += 1 ;	
			received_bytes += (pcktSize-header);
			received_time[idPacket] = time_sec ;
			rDelay[idPacket] = received_time[idPacket] - rSentTime[idPacket ];
			total_delay += rDelay[idPacket]; 
		}

		if (strEvent == "d") {
			dropped_packets += 1;
		}
	}
}

END {
    simulation_time = end_time - start_time;

    # print "Sent Packets: ", sent_packets;
    # print "Dropped Packets: ", dropped_packets;
    # print "Received Packets: ", received_packets;
    # print "Simulation time: ", simulation_time;
    
    print "-------------------------------------------------------------";
    print "Throughput: ", (received_bytes * 8) / simulation_time, "bits/sec";
    print "Average Delay: ", (total_delay / received_packets), "seconds";
    print "Delivery ratio: ", (received_packets / sent_packets) * 100, "%";
    print "Drop ratio: ", (dropped_packets / sent_packets) * 100, "%";

    print "", (received_bytes * 8) / simulation_time, ", ", (total_delay / received_packets), ", ", (received_packets / sent_packets) * 100, ", ", (dropped_packets / sent_packets) * 100, ", ",  total_energy_consumed >> output_file;
}