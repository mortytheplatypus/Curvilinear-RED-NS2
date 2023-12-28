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
Queue/RED set isCLRED_ [lindex $argv 3] 

# ======================================================================
# Define metrics
set val(nn) [lindex $argv 0]
set val(nf) [lindex $argv 1]
set val(pps) [lindex $argv 2]

# ======================================================================
# trace file
set trace_file [open trace.tr w]
$ns trace-all $trace_file

# nam file
set nam_file [open animation.nam w]
$ns namtrace-all $nam_file 

set node(b1) [$ns node]
set node(b2) [$ns node]

set val(nnn) [expr {($val(nn) - 2) / 2}]

for {set i 0} {$i < $val(nnn)} {incr i} {
    set node(s$i) [$ns node]
    $ns duplex-link $node(s$i) $node(b1) 10Mb 2ms DropTail
}

$ns duplex-link $node(b1) $node(b2) 1.5Mb 20ms RED 
$ns queue-limit $node(b1) $node(b2) 30
$ns queue-limit $node(b2) $node(b1) 30

for {set i 0} {$i < $val(nnn)} {incr i} {
    set node(d$i) [$ns node]
    $ns duplex-link $node(d$i) $node(b2) 10Mb 2ms DropTail
}

$ns duplex-link-op $node(b1) $node(b2) orient right
$ns duplex-link-op $node(b1) $node(b2) queuePos 0
$ns duplex-link-op $node(b2) $node(b1) queuePos 0

for {set i 0} {$i < $val(nf)} {incr i} {
    set src [expr int(1000 * rand()) % $val(nnn)] 
    set dest [expr int(1000 * rand()) % $val(nnn)]
    
    set tcp($i) [new Agent/TCP]
    set sink($i) [new Agent/TCPSink]

    $ns attach-agent $node(s$src) $tcp($i)
    $ns attach-agent $node(d$dest) $sink($i)

    $tcp($i) set packetSize_ 1000
    $tcp($i) set rate_ 200kb
    $tcp($i) set window_ $val(pps)

    $ns connect $tcp($i) $sink($i)
    $tcp($i) set fid_ $i

    set ftp($i) [new Application/FTP]
    $ftp($i) attach-agent $tcp($i)

    $ns at 0.2 "$ftp($i) start"
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
