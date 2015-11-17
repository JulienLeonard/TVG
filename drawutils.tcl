
proc drawcircle {circle color} {
    global render
    if {[llength $circle] != 3} {
	error "circle $circle bad syntax (must be length 3)"
    }
    
    if {[llength $color] != 4} {
	error "color $color bad syntax (must be length 4)"
    }
    
    render circle $circle $color
}

proc drawpolygon {polygon color} {
    global render
    if {[llength $color] != 4} {
	error "color $color bad syntax (must be length 4)"
    }
    
    render polygon $polygon $color
}

proc drawpolygonfrompoints {polygon color} {
    drawpolygon [lflatten $polygon] $color
}


proc drawbezier {bezier color} {
    global render
    if {[llength $color] != 4} {
	error "color $color bad syntax (must be length 4)"
    }
    
    render bezier $bezier $color
}

proc drawrect {rect color} {
    global render
    if {[llength $color] != 4} {
	error "color $color bad syntax (must be length 4)"
    }
    
    render polygon [rectcoords $rect] $color
}




proc drawcircles {circles {colors {{1.0 1.0 1.0 1.0}}}} {
    if {[llength $colors] == 1} {
	foreach circle $circles {
	    drawcircle $circle [lindex $colors 0]
	}
    } elseif {[llength $colors] == 4} {
	foreach circle $circles {
	    drawcircle $circle $colors
	}
    } else {
	forzip circle $circles color $colors {
	    # puts "circle $circle color $color"
	    drawcircle $circle $color
	}
    }
}

proc drawcrown {circle pattern} {
    foreach {color radiusfactor} $pattern {
	drawcircle [circle $circle radius *$radiusfactor] $color
    }
}

proc drawcrowns {circles pattern} {
    foreach circle $circles {
	drawcrown $circle $pattern
    }
}


proc drawcircleflat {x y r red green blue opacity} {
    puts "drawcircleflat"
    drawcircle [list $x $y $r] [list $red $green $blue $opacity]
}


proc drawinit {width height filepath background} {
    global render
    # global collision
    # global tangentproxy

    puts "drawinit width $width height $height filepath $filepath background $background"
    load "CVGPROXY.dll" cvgproxy
    RenderProxy render
    render init $width $height $filepath $background
    # CollisionProxy collision
    # TangentProxy tangentproxy
    puts "drawinit end"
}

proc drawend {} {
    global render
    # global collision
    # global tangentproxy

    puts "drawend"
    render end
    puts "drawend before rename"
    rename render ""
    # rename collision ""
    # rename tangentproxy ""
    puts "drawend end"
}

proc focus {xc yc size} {
    global render

    render focus $xc $yc $size
}