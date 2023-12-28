# simulator
set ns [new Simulator]

# ======================================================================
# Define RED parameters 
Queue/RED set thresh_queue_ 10
Queue/RED set maxthresh_queue_ 30
Queue/RED set q_weight_ 0.002
Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ false
Queue/RED set gentle_ false
Queue/RED set mean_pktsize_ 1000
Queue/RED set isCLRED_ [lindex $argv 4] 

# ======================================================================
# Define options
set val(chan)         Channel/WirelessChannel  ; # channel type
set val(prop)         Propagation/TwoRayGround ; # radio-propagation model
set val(ant)          Antenna/OmniAntenna      ; # Antenna type
set val(ll)           LL                       ; # Link layer type
set val(ifq)          Queue/RED                ; # Interface queue type
set val(ifqlen)       50                       ; # max packet in ifq
set val(netif)        Phy/WirelessPhy          ; # network interface type
set val(mac)          Mac/802_11               ; # MAC type
set val(rp)           DSDV                     ; # ad-hoc routing protocol 

# =======================================================================
# Define energy model
set val(energyModel)  EnergyModel
set val(initEn)       100.0
set val(idlePwr)      0.01
set val(rxPwr)        1.0
set val(txPwr)        1.0
set val(sleepPwr)     0.05

# =======================================================================
# Define metrics
set val(len)          [lindex $argv 0]         ; # length of one side of area
set val(nn)           [lindex $argv 1]         ; # number of mobilenodes
set val(nf)           [lindex $argv 2]         ; # number of flows
set val(pps)          [lindex $argv 3]         ; # packets per second
# =======================================================================

# trace file
set trace_file [open trace.tr w]
$ns trace-all $trace_file

# nam file
set nam_file [open animation.nam w]
$ns namtrace-all-wireless $nam_file $val(len) $val(len)

# topology: to keep track of node movements
set topo [new Topography]
$topo load_flatgrid $val(len) $val(len) ;

# general operation director for mobilenodes
create-god $val(nn)

$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -topoInstance $topo \
                -energyModel $val(energyModel) \
                    -initialEnergy $val(initEn) \
                    -idlePower $val(idlePwr) \
                    -sleepPower $val(sleepPwr) \
                    -rxPower $val(rxPwr) \
                    -txPower $val(txPwr) \
                -channelType $val(chan) \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace OFF \
                -movementTrace OFF

# create grid
set row 5
set col 4
if {$val(nn) == 40} {
	set row 8       ; # 8*5 = 40
    set col 5 
} elseif {$val(nn) == 60} {
	set row 10      ; # 10*6 = 60
    set col 6      
} elseif {$val(nn) == 80} {
    set row 10      ; # 10*8 = 80
	set col 8      
} elseif {$val(nn) == 100} {
	set row 10      ; # 10*10 = 100
	set col 10
}

# create nodes
for {set i 0} {$i < $row } {incr i} {
    for {set j 0} {$j < $col } {incr j} {
        set nodeNo [expr ($i*$col + $j)]
        set node($nodeNo) [$ns node]

        set tmp [expr ($val(len)/10)]

        $node($nodeNo) set X_ [expr ($tmp + 2*$tmp*$j)]
        $node($nodeNo) set Y_ [expr ($tmp + 2*$tmp*$i)]
        $node($nodeNo) set Z_ 0   

        $ns initial_node_pos $node($nodeNo) 30
    }
} 

# create flows := random source <-> 1 sink
set dest [expr int(1000 * rand()) % $val(nn)]

for {set i 0} {$i < $val(nf)} {incr i} {
    set src [expr int(1000 * rand()) % $val(nn)]    ; # random source
    
    # check if src and dest are same
    while { $src == $dest } {
        set src [expr int(1000 * rand()) % $val(nn)]
    }

    set tcp($i) [new Agent/TCP]
    set sink($i) [new Agent/TCPSink]

    $ns attach-agent $node($src) $tcp($i)
    $ns attach-agent $node($dest) $sink($i)

    $tcp($i) set packetSize_ 1000
    $tcp($i) set rate_ 200kb
    $tcp($i) set window_ $val(pps)

    $ns connect $tcp($i) $sink($i)
    $tcp($i) set fid_ $i

    set ftp($i) [new Application/FTP]
    $ftp($i) attach-agent $tcp($i)
    
    $ns at 0.2 "$ftp($i) start"
}

# Stop nodes
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at 22.0 "$node($i) reset"
}

proc finish {} {
    global ns trace_file nam_file
    $ns flush-trace
    close $trace_file
    close $nam_file
}

proc halt_simulation {} {
    global ns
    puts "Simulation ending"
    $ns halt
}

$ns at 20.01 "finish"
$ns at 20.21 "halt_simulation"

# Run simulation
puts "Simulation starting"
$ns run
