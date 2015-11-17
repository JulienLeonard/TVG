source utils.tcl
# segment = {{x1 y1} {x2 y2}}

#@ [raw-intersection -1.0 0.0 1.0 0.0 0.0 -1.0 0.0 1.0] -> {0.0 0.0}
#@ [raw-intersection  0.0 0.0 1.0 0.0 0.0 -1.0 0.0 1.0] -> {0.0 0.0}
#@ [raw-intersection  0.0 0.0 1.0 0.0 0.0  0.0 0.0 1.0] -> {0.0 0.0}
#@ [raw-intersection  0.5 0.0 1.0 0.0 0.0  0.0 0.0 1.0] -> {}
#@ [raw-intersection  0.5 0.0 1.0 0.0 0.0  0.5 0.0 2.0 0.0] -> {all all}
proc raw-intersection {x1 y1 x2 y2 x3 y3 x4 y4} {
    set denom [- [* [- $y4 $y3] [- $x2 $x1]] [* [- $x4 $x3] [- $y2 $y1]]]
    set uanum [- [* [- $x4 $x3] [- $y1 $y3]] [* [- $y4 $y3] [- $x1 $x3]]]
    set ubnum [- [* [- $x2 $x1] [- $y1 $y3]] [* [- $y2 $y1] [- $x1 $x3]]]
    if {$denom == 0.0 && $uanum == 0.0 && $ubnum == 0.0} {
	return [list all all]
    } elseif {$denom == 0.0} {
	return [list]
    } else {
	set ua [/ $uanum $denom]
	set ub [/ $ubnum $denom]
	if {$ua >= 0 && $ua <= 1 && $ub >= 0 && $ub <= 1} {
	    set x [+ $x1 [* $ua [- $x2 $x1]]]
	    set y [+ $y1 [* $ua [- $y2 $y1]]]
	    return [list $x $y]
	}
	return [list]
    }
}

proc intersection {sega segb} {
    foreach {p1 p2} $sega break
    foreach {p3 p4} $segb break
    foreach i {1 2 3 4} {
	foreach [list x$i y$i] [set p$i] break
    }
    return [raw-intersection $x1 $y1 $x2 $y2 $x3 $y3 $x4 $y4]
}

proc seglist-intersection {seglist1 seglist2} {
    set result1 [list]
    set cresult1 [list]
    forpair p11 p12 $seglist1 {
	set inter [list]
	forpair p21 p22 $seglist2 {
	    # TODO: if several intersections on same seg1 for different seg2 !!!
	    set inter [intersection [list $p11 $p12] [list $p21 $p22]]
	    if {[llength $inter]} {
		break
	    }
	}
	if {[llength $inter]} {
	    if {[s= [lfront $inter] all]} {
		# TODO 
	    } else {
		lappend cresult1 $p11 $inter
		lappend result1 [ltrimequal $cresult1]
		set cresult1 [list $inter $p12]
	    }
	} else {
	    lappend cresult1 $p11 $p12
	}
    }
    lappend result1 [ltrimequal $cresult1]
    return $result1
}

# seg points define a list
# close the line by making an offset and reverse
proc offset {segpoints width} {
    set newpoints [list]
    forpair p1 p2 $segpoints {
	set v [vscale [vortho [vnorm [vector $p1 $p2]]]  [- 0.0 $width]]
	lappend newpoints [padd $p1 $v] [padd $p2 $v]
    }
    # foreach {p1 p2} [lrange $segpoints end-1 end] break
    # puts "$p1 $p2"
    set points $newpoints
    set newpoints [list [lfront $points]]
    for {set index 0} {$index < [llength $points] - 2} {incr index 2} {
	foreach {p11 p12 p21 p22} [lrange $points $index [+ $index 4]] break
	if {[p= $p12 $p21]} {
	    lappend newpoints $p12
	} else {
	    set interpoint [intersection [list $p11 $p12] [list $p21 $p22]]
	    if {![llength $interpoint]} {
		lappend newpoints $p12 $p21
	    } else {
		lappend newpoints $interpoint
	    }
	}
    }
    lappend newpoints [lback $points]
    # lappend newpoints [padd $p2 [vscale [vreverse [vortho [vnorm [vector $p2 $p1]]]] [- 0.0 $width]]]
    return $newpoints
}

proc offsetvar {segpoints specvar} {
    set newpoints [list]
    set index 0
    forpair p1 p2 $segpoints {
	set abs [/ [double $index] [double [llength $segpoints]]]
	lappend newpoints [padd $p1 [vscale [vortho [vnorm [vector $p1 $p2]]]  [multisample $specvar $abs]]]
	incr index
    }
    foreach {p1 p2} [lrange $segpoints end-1 end] break
    # puts "$p1 $p2"
    lappend newpoints [padd $p2 [vscale [vreverse [vortho [vnorm [vector $p2 $p1]]]] [multisample $specvar 1.0]]]
    return $newpoints
}


proc closepolygon {segpoints width} {
    set result [lconcat $segpoints [lreverse [offset $segpoints $width]]]
    return $result
}

proc enveloppe {segpoints width1 width2} {
    set result [lconcat [offset $segpoints $width1] [lreverse [offset $segpoints $width2]]]
    return $result
}


proc segcoords {seg} {
    foreach {p1 p2} $seg break
    foreach {x1 y1} $p1 break
    foreach {x2 y2} $p2 break
    return [list $x1 $y1 $x2 $y2]
}

proc nextpoint {point angle radius} {
    foreach {x y} $point break
    set length $radius
    set newx [expr {$x + $length * cos($angle)}]
    set newy [expr {$y + $length * sin($angle)}]
    return [list $newx $newy]
}

proc seqpoints {seed radiuss angles} {
    set points [list $seed]
    foreach {radius angle} [lzip $radiuss $angles] {
	lappend points [nextpoint [lback $points] $angle $radius]
    }
    return $points
}


# algo: rotate curve so that first and last point are angled 0.0
proc levelcurve {segpoints} {
    set angle [vangle [vector [lback $segpoints] [lfront $segpoints]]]
    # puts "levelcurve angle $angle"
    return [map p $segpoints {padd [lfront $segpoints] [vrotate [vector $p [lfront $segpoints]] [- 0.0 $angle]]}]
}

# return ys, once curve has been levelled
proc segpointlevels {segpoints} {
    set lsegpoints [levelcurve $segpoints]
    return [map p $segpoints {lback $p}]
}

proc segpoint {p1 p2 abs} {
    puts "seg $seg abs $abs"
    foreach {p1 p2} $seg break
    foreach {x1 y1} $p1 break
    foreach {x2 y2} $p2 break
    set result [list [sample [list $x1 $x2] $abs] [sample [list $y1 $y2] $abs]]
    puts "segpoint $result"
    return $result
}

proc seglistpoint {points abs} {
    set pindex [int [* $abs [double [llength $points]]]] 
    return [lindex $points $pindex]
}

proc seglistseg {points abs} {
    set pindex [int [* $abs [double [llength $points]]]]
    if {$pindex == [llength $points] - 1} {
	return [lrange $points end-1 end]
    } else { 
	return [lrange $points $pindex [+ $pindex 1]]
    }
}

proc seglistlength {points} {
    # puts "seglistlengths $points"
    set l 0
    forpair p1 p2 $points {
	set cl [vlength [vector $p2 $p1]]
	set l [+ $l $cl]
    }
    return $l
}


proc seglistlengths {points} {
    # puts "seglistlengths $points"
    set result [list]
    set l 0
    lappend result [list [lfront $points] 0.0]
    forpair p1 p2 $points {
	set cl [vlength [vector $p2 $p1]]
	set l [+ $l $cl]
	lappend result [list $p2 $l]
    }
    return $result
}

proc seglistframe {points abs} {
    set lengths     [seglistlengths $points]
    set lengthrange [list [lback [lfront $lengths]] [lback [lback $lengths]]]
    set clength     [sample $lengthrange $abs]

    forpair pl1 pl2 $lengths {
	if {[lback $pl1] <= $clength &&  $clength <= [lback $pl2]} {
	    break
	}
    }

    foreach {p1 l1} $pl1 break
    foreach {p2 l2} $pl2 break
    set absl [abscissa [list $l1 $l2] $clength]
    set newp [psample $p1 $p2 $absl]

    set normal [vortho [vnorm [vector $p2 $p1]]]
    return [list $newp $normal]
}

proc seglistsplit {points abs} {
    # puts "seglistsplit $points $abs"
    set lengths     [seglistlengths $points]
    set lengthrange [list [lback [lfront $lengths]] [lback [lback $lengths]]]
    set clength     [sample $lengthrange $abs]

    # puts "clength $clength lengths $lengths"
    set pindex 0
    forpair pl1 pl2 $lengths {
	if {[lback $pl1] <= $clength &&  $clength <= [lback $pl2]} {
	    break
	}
	incr pindex
    }

    foreach {p1 l1} $pl1 break
    foreach {p2 l2} $pl2 break
    set absl [abscissa [list $l1 $l2] $clength]
    set newp [psample $p1 $p2 $absl]

    # puts "newp $newp"
    set points1 [lconcat [lrange $points 0 $pindex] [list $newp]]
    incr pindex
    set points2 [lconcat [list $newp] [lrange $points $pindex end]]
    # puts "seglistsplit result $points1 $points2"
    return [list $points1 $points2]
}


# repere is {pa pb pc}
proc curvemap {points repere} {

}

# algo:
# - compute angle between segs
# - then compute nsegments from a circle with first angle and last angle 
proc fittingcurve {sega segb} {
    # TODO

}

proc levelmultisamples {levels} {
    set result [list]
    foreach l [lrange $levels 0 end-1] {
	lappend result $l 1
    }
    lappend result [lback $levels]
    return $result
}

proc seglistrangex {seglist} {
    set xlist [map p $seglist {px $p}]
    return [range $xlist]
}

proc seglistrangey {seglist} {
    set ylist [map p $seglist {py $p}]
    return [range $ylist]
}

proc offsetvarx {curve1 curve2} {
    set curve2  [levelcurve $curve2]
    set rangex2 [seglistrangex $curve2]
    set rangey2 [seglistrangey $curve2]

    set rangey1 [seglistrangey $curve1]
    # set yfactor [/ [double [- [lback $rangex1] [lfront $rangex1]]] [double [- [lback $rangex2] [lfront $rangex2]]]]
    
    set result [list]
    foreach p2 $curve2 {
	set abs [abscissa $rangex2 [px $p2]]

	foreach {newp normal} [seglistframe $curve1 $abs] break
	
	lappend result [padd $newp [vscale $normal [py $p2]]]
    }
    return $result
}