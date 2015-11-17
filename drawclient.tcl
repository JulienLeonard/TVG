puts "start client"
cd c:/dev/cvg/scripts

source utils.tcl
source drawutils.tcl
source utils.tcl
source drawutils.tcl
source geoutils.tcl
source circleiterator.tcl
source sequenceutils.tcl
source color.tcl


proc drawconnect {host port} {
    set s [socket $host $port]
    fconfigure $s -buffering line
    return $s
}

proc drawcommand {chan} {
    global output
    if {[gets $chan line] < 0} {
      if {[eof $chan]} {
         close $chan
         return
      }
   } else {
       eval $line
   }
}

proc end {} {
    global s
    close $s
    drawend
}

global s
# A sample client session looks like this
set s [drawconnect localhost 45000]
fileevent $s readable "drawcommand $s"
vwait forever