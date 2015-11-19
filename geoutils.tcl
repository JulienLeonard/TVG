
proc circle {args} {
    if {[llength $args] == 3} {
	lassign $args circle prop modif
	lassign $circle x y radius
	set $prop [expr "[set $prop] $modif"]
	return [list $x $y $radius]
    } elseif {[llength $args] == 2} {
	lassign $args circle prop
	lassign $circle x y radius
	return [set $prop]
    }
}

proc circlefromdiameter {p1 p2} {
    set center [pmiddle $p1 $p2]
    set radius [/ [vlength [vector [circlecenter $p1] [circlecenter $p2]]] 2.0]
    return [lconcat $center [list $radius]]
}

proc circlecenter {list} {
    return [lrange $list 0 1]
}

proc circlebbox {circle} {
    foreach {x y r} $circle break
    return [list [- $x $r] [- $y $r] [+ $x $r] [+ $y $r]] 
}

proc bbox2circle {bbox} {
    foreach {x1 y1 x2 y2} $bbox break
    set width  [- $x2 $x1]
    set height [- $y2 $y1]

    set r [/ [lmin [list $width $height]] 2.0]
    set x [lmean [list $x1 $x2]]
    set y [lmean [list $y1 $y2]]
    return [list $x $y $r]
}

if {1} {
    proc bboxcircle {circles} {
	# set bb2circle [bbox2circle [maxbbox [map circle $circles {circlebbox $circle}]]]
	# foreach {rx ry rr} $bb2circle break
	set rx 0.0; # set rx [lmean [map circle $circles {circle $circle x}]]
	set ry 0.0; # [lmean [map circle $circles {circle $circle y}]]
	set rp [list $rx $ry]
	# set rp [list 0.0 0.0]
	
	set maxdist [lmax [map circle $circles {+ [vlength [vector [circlecenter $circle] $rp]] [circle $circle radius]}]]
	return [list $rx $ry $maxdist]
    }
}

if {0} {
# compute distance+radius between every circle, and diameter is max
proc bboxcircle {circles} {
    set mmaxdist 0.0
    set couple ""
    foreach circle $circles {
	set maxdist 0.0
	set ccircle ""
	foreach ocircle $circles {
	    set dist [+ [vlength [vector [circlecenter $circle] [circlecenter $ocircle]]] [circle $ocircle radius]]
	    if {$dist > $maxdist} {
		set maxdist $dist
		set ccircle $ocircle
	    }
	}
	if {$maxdist > $mmaxdist} {
	    set mmaxdist $maxdist
	    set couple [list $circle $ccircle]
	}
    }

    foreach {c1 c2} $couple break
    set p [pmiddle [circlecenter $c1] [circlecenter $c2]]
    set r [+ [/ [vlength [vector [circlecenter $c1] [circlecenter $c2]]] 2.0] [lmax [list [circle $c1 radius] [circle $c2 radius]]]] 
    
    return [list [lfront $p] [lback $p] $r]
}
}

proc circletranslate {circle vector} {
    foreach {x y r} $circle break
    foreach {vx vy} $vector break
    return [list [+ $x $vx] [+ $y $vy] $r]
}

proc circlescale {circle scale} {
    foreach {x y r} $circle break
    return [list $x $y [* $r $scale]]
}

proc circletranscale {circle circle1 circle2} {
    foreach {x y r}    $circle  break
    foreach {x1 y1 r1} $circle1 break
    foreach {x2 y2 r2} $circle2 break

    set vx1 [- $x $x1]
    set vy1 [- $y $y1]
    set newx [+ $x2 [* [/ $vx1 $r1] $r2]]
    set newy [+ $y2 [* [/ $vy1 $r1] $r2]]
    set newr [* [/ $r $r1] $r2]
    return [list $newx $newy $newr]
}


proc maxbbox {bboxes} {
    set xmin [lmin [map bbox $bboxes {lindex $bbox 0}]]
    set ymin [lmin [map bbox $bboxes {lindex $bbox 1}]]
    set xmax [lmax [map bbox $bboxes {lindex $bbox 2}]]
    set ymax [lmax [map bbox $bboxes {lindex $bbox 3}]]
    return [list $xmin $ymin $xmax $ymax]
}


proc px {p} {
    return [lindex $p 0]
}

proc py {p} {
    return [lindex $p 1]
}

proc p= {p1 p2} {
    if {[px $p1] == [px $p2] &&  [py $p1] == [py $p2]} {
	return 1
    }
    return 0
}

proc psample {p1 p2 abs} {
    foreach {x1 y1} $p1 break
    foreach {x2 y2} $p2 break
    set newx [sample [list $x1 $x2] $abs]
    set newy [sample [list $y1 $y2] $abs]
    return [list $newx $newy]
}

proc lpmiddle {points} {
    set xs [map p $points {px $p}]
    set ys [map p $points {py $p}]
    return [list [lmean $xs] [lmean $ys]]
}

proc pmiddle {p1 p2} {
    return [lpmiddle [list $p1 $p2]]
}

proc pweight {p1 r1 p2 r2} {
    foreach {x1 y1} $p1 break
    foreach {x2 y2} $p2 break
    set newx [expr {($x1 * $r1 + $x2 * $r2)/($r1 + $r2)}]
    set newy [expr {($y1 * $r1 + $y2 * $r2)/($r1 + $r2)}]
    return [list $newx $newy]
}


proc vector {p2 p1} {
    return [list [expr {[px $p2] - [px $p1]}] [expr {[py $p2] - [py $p1]}]]
}

proc vortho {v} {
    return [list [expr {-[py $v]}] [px $v]]
}

proc padd {p v} {
    return [list [expr {[px $p] + [px $v]}] [expr {[py $p] + [py $v]}]]
}

proc vreverse {v} {
    return [list [- 0.0 [px $v]] [- 0.0 [py $v]]]
}

proc vscale {v scale} {
    return [list [expr {[px $v] * $scale}] [expr {[py $v] * $scale}]]
}

proc vlength {v} {
    return [expr {hypot([px $v],[py $v])}]
}

proc vnorm {v} {
    return [vscale $v [/ 1.0 [vlength $v]]]
}

proc vangle {v} {
    foreach {x y} $v break
    set angle [tcl::mathfunc::atan2 $y $x]
    return $angle
}

proc vrotate {v angle} {
    set sin [expr {sin($angle)}]
    set cos [expr {cos($angle)}]
    foreach {x y} $v break
    return [list [- [* $x $cos] [* $y $sin]] [+ [* $x $sin] [* $y $cos]]]
}

proc circlepoint {circle abscissa} {
    foreach {xc yc r} $circle break
    set angle [sample [list 0.0 [* 2 3.14156]] $abscissa]
    set x [expr {$xc + $r * cos( $angle ) + $r *sin( $angle )}] 
    set y [expr {$yc - $r * sin( $angle ) + $r *cos( $angle )}]
    return [list $x $y]
}

proc circlesamples {circle abscissas} {
    return [map abs $abscissas {circlepoint $circle $abs}]
}

proc rect {args} {
    setargs

    ifset x1 xl
    ifset x1 xleft
    ifset y1 yl
    ifset y1 yleft

    ifset x2 xr
    ifset x2 xright
    ifset y2 yr
    ifset y2 yright

    if {([info exists xc] || [info exists xcenter]) && ([info exists yc] || [info exists ycenter])} {
	checkargs width height
	ifset xc xcenter
	ifset yc ycenter
	set x1 [- $xc [/ $width 2.0]]
	set x2 [+ $xc [/ $width 2.0]]
	set y1 [- $yc [/ $height 2.0]]
	set y2 [+ $yc [/ $height 2.0]]
    } elseif {[info exists x1] && [info exists width]} {
	set x2 [+ $x1 $width]
	set y2 [+ $y1 $height]
    }
    
    return [list $x1 $y1 $x2 $y2]
}

proc rectcoords {rect} {
    lassign $rect x1 y1 x2 y2
    return [list $x1 $y1 $x2 $y1 $x2 $y2 $x1 $y2]    
}

proc rectinside {rect xmargin {ymargin ""}} {
    if {![string length $ymargin]} {
	set xmargin $ymargin
    }

    lassign $rect x1 y1 x2 y2
    set newx1 [+ $x1 $xmargin]
    set newy1 [+ $y1 $ymargin]
    set newx2 [- $x2 $xmargin]
    set newy2 [- $y2 $ymargin]
    return [list $newx1 $newy1 $newx2 $newy2]
}

proc rectsplit {rect ratios splitwidth} {
    lassign $rect x1 y1 x2 y2

    if {$splitwidth} {
	set newxs [lconcat $x1 [map ratio $ratios {sample [list $x1 $x2] $ratio}] $x2]
	set result [list]
	forpair x1 x2 $newxs {lappend result [rect -x1 $x1 -y1 $y1 -x2 $x2 -y2 $y2]}
	return $result
    } else {
	set newys [lconcat $y1 [map ratio $ratios {sample [list $y1 $y2] $ratio}] $y2]
	set result [list]
	forpair y1 y2 $newys {lappend result [rect -x1 $x1 -y1 $y1 -x2 $x2 -y2 $y2]}
	return $result
    }
}

proc rectgrid {rect ratioxs ratioys} {
    set wbands [rectsplit $rect $ratioys 1]
    set result [list]
    foreach wband $wbands {
	eval lappend result [rectsplit $wband $ratioxs 0]
    }
    return $result
}
