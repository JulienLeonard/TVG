puts "start client"
cd c:/dev/cvg/scripts

source utils.tcl
source color.tcl
source svgrender2.tcl

proc drawinit {width height filepath background} {
    global rendersvg0

    SVGRENDER2 create rendersvg0 $width $height $filepath
}

proc drawpolygon {polygon color} {
    global rendersvg0
    if {[llength $color] != 4} {
	error "color $color bad syntax (must be length 4)"
    }
    
    rendersvg0 drawline -coords $polygon -fillcolor $color -filled 1 -priority 1
}

proc drawcircle {circle color} {
    global rendersvg0
    if {[llength $color] != 4} {
	error "color $color bad syntax (must be length 4)"
    }
    
    rendersvg0 drawcircle -coords $circle -fillcolor $color -filled 1 -priority 1
}



proc focus {xc yc size} {
    global rendersvg0

    rendersvg0 setfocus $xc $yc $size
}

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
    global rendersvg0
    rendersvg0 dump
    close $s
}

global s
# A sample client session looks like this
set s [drawconnect localhost 45000]
fileevent $s readable "drawcommand $s"
vwait forever