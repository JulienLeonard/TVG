package require XOTcl; namespace import ::xotcl::*

if {0} {
if {[llength [Class info classchildren COLOR]]} {
    return
}
}

# source "listtools.tcl"
# source "mathtools.tcl"
source GC.tcl

Class COLOR -superclass REFCOUNT -parameter {{r 1.0} {g 1.0} {b 1.0} {a 1.0}}

COLOR instproc init {r g b a} {
    foreach v {r g b a} {
	my $v [set $v]
    }
    next
}

COLOR instproc copy {} {
    return [COLOR new [my r] [my g] [my b] [my a]]
}

COLOR instproc rgba {} {
    return [list [my r] [my g] [my b] [my a]]
}

COLOR instproc rgb {} {
    return [list [my r] [my g] [my b]]
}

COLOR instproc hsva {} {
    return [lconcat [rgb2hsv [my r] [my g] [my b]] [my a]]
}

COLOR instproc hsv {} {
    return [rgb2hsv [my r] [my g] [my b]]
}

if {0} {
foreach proc {rgba rgb hsva hsv} {
   proc $proc {color} {
       if {[llength $color] > 1} {
	   return $color
       } else {
	   return [$color $proc]
       }
   }
}
}

proc rgba {color} {
    if {[llength $color] > 1} {
	return $color
    } else {
	return [$color rgba]
    }
}

COLOR instproc get_svg {} {
    set svgvalues [map v [list [my r] [my g] [my b]] {expr {int(255.0 * $v)}}]
    return "rgb([join $svgvalues ,])"
}

COLOR instproc op {other op} {
    foreach v {r g b a} {
	set new$v [expr [my $v] $op [$other $v]]
    }

    set result [COLOR new $newr $newg $newb $newa]
    return $result
}

COLOR instproc add {other} {
    return [my op $other +]
}

COLOR instproc sub {other} {
    return [my op $other -]
}


COLOR instproc mult {scalar} {
    foreach v {r g b a} {
	set new$v [expr {[my $v] * $scalar}]
    }

    set result [COLOR new $newr $newg $newb $newa]
    return $result
}

COLOR instproc opacity {} {
    return [my a]
}


Class PALETTE -parameter {colorlist}
# colorlist : list color dindex
PALETTE instproc init {args} {
    foreach {color index} [my colorlist] {
	if {[llength $color] > 1} {
	    set color [eval COLOR new $color]
	} 
	$color reserve
    }
}

PALETTE instproc color {dindex} {
    # puts "color $dindex"

    set pcolor [lindex [my colorlist] 0]
    set pindex [lindex [my colorlist] 1]
    
    foreach {color index} [my colorlist] {
	if {$dindex <= $index} {
	    # puts "color [$color get_svg] index $index"
	    if {$dindex == $index} {
		return $color
	    }
	    set result [$pcolor add [[$color sub $pcolor] mult [expr {($dindex - $pindex)/($index-$pindex)}]]]
	    break
	}
	set pcolor $color
	set pindex $index
    }

    if {![info exists result]} {
	set result [lindex [my colorlist] end-1]
    }

    # puts "result [$result get_svg]"
    return $result
}

PALETTE instproc colors {indexes} {
    return [map index $indexes {my color $index}]
}

PALETTE instproc rand {} {
    return [my color [expr {rand()}]]
}

# rgb2hsv --
 #
 #       Convert a color value from the RGB model to HSV model.
 #
 # Arguments:
 #       r g b  the red, green, and blue components of the color
 #               value.  The procedure expects, but does not
 #               ascertain, them to be in the range 0 to 1.
 #
 # Results:
 #       The result is a list of three real number values.  The
 #       first value is the Hue component, which is in the range
 #       0.0 to 360.0, or -1 if the Saturation component is 0.
 #       The following to values are Saturation and Value,
 #       respectively.  They are in the range 0.0 to 1.0.
 #
 # Credits:
 #       This routine is based on the Pascal source code for an
 #       RGB/HSV converter in the book "Computer Graphics", by
 #       Baker, Hearn, 1986, ISBN 0-13-165598-1, page 304.
 #

 proc rgb2hsv {r g b} {
     set h [set s [set v 0.0]]]
     set sorted [lsort -real [list $r $g $b]]
     set v [expr {double([lindex $sorted end])}]
     set m [lindex $sorted 0]

     set dist [expr {double($v-$m)}]
     if {$v} {
         set s [expr {$dist/$v}]
     }
     if {$s} {
         set r' [expr {($v-$r)/$dist}] ;# distance of color from red
         set g' [expr {($v-$g)/$dist}] ;# distance of color from green
         set b' [expr {($v-$b)/$dist}] ;# distance of color from blue
         if {$v==$r} {
             if {$m==$g} {
                 set h [expr {5+${b'}}]
             } else {
                 set h [expr {1-${g'}}]
             }
         } elseif {$v==$g} {
             if {$m==$b} {
                 set h [expr {1+${r'}}]
             } else {
                 set h [expr {3-${b'}}]
             }
         } else {
             if {$m==$r} {
                 set h [expr {3+${g'}}]
             } else {
                 set h [expr {5-${r'}}]
             }
         }
         set h [expr {$h*60}]          ;# convert to degrees
     } else {
         # hue is undefined if s == 0
         set h -1
     }
     return [list $h $s $v]
 }

 # hsv2rgb --
 #
 #       Convert a color value from the HSV model to RGB model.
 #
 # Arguments:
 #       h s v  the hue, saturation, and value components of
 #               the color value.  The procedure expects, but
 #               does not ascertain, h to be in the range 0.0 to
 #               360.0 and s, v to be in the range 0.0 to 1.0.
 #
 # Results:
 #       The result is a list of three real number values,
 #       corresponding to the red, green, and blue components
 #       of a color value.  They are in the range 0.0 to 1.0.
 #
 # Credits:
 #       This routine is based on the Pascal source code for an
 #       HSV/RGB converter in the book "Computer Graphics", by
 #       Baker, Hearn, 1986, ISBN 0-13-165598-1, page 304.
 #

 proc hsv2rgb {h s v} {
     set v [expr {double($v)}]
     set r [set g [set b 0.0]]
     if {$h == 360} { set h 0 }
     # if you feed the output of rgb2hsv back into this
     # converter, h could have the value -1 for
     # grayscale colors.  Set it to any value in the
     # valid range.
     if {$h == -1} { set h 0 }
     set h [expr {$h/60}]
     set i [expr {int(floor($h))}]
     set f [expr {$h - $i}]
     set p1 [expr {$v*(1-$s)}]
     set p2 [expr {$v*(1-($s*$f))}]
     set p3 [expr {$v*(1-($s*(1-$f)))}]
     switch -- $i {
         0 { set r $v  ; set g $p3 ; set b $p1 }
         1 { set r $p2 ; set g $v  ; set b $p1 }
         2 { set r $p1 ; set g $v  ; set b $p3 }
         3 { set r $p1 ; set g $p2 ; set b $v  }
         4 { set r $p3 ; set g $p1 ; set b $v  }
         5 { set r $v  ; set g $p1 ; set b $p2 }
     }
     return [list $r $g $b]
 }

proc hls2rgb {h l s} {
    # h, l and s are floats between 0.0 and 1.0, ditto for r, g and b
    # h = 0   => red
    # h = 1/3 => green
    # h = 2/3 => blue

    set h6 [expr {($h-floor($h))*6}]
    set r [expr {  $h6 <= 3 ? 2-$h6
                            : $h6-4}]
    set g [expr {  $h6 <= 2 ? $h6
                            : $h6 <= 5 ? 4-$h6
                            : $h6-6}]
    set b [expr {  $h6 <= 1 ? -$h6
                            : $h6 <= 4 ? $h6-2
                            : 6-$h6}]
    set r [expr {$r < 0.0 ? 0.0 : $r > 1.0 ? 1.0 : double($r)}]
    set g [expr {$g < 0.0 ? 0.0 : $g > 1.0 ? 1.0 : double($g)}]
    set b [expr {$b < 0.0 ? 0.0 : $b > 1.0 ? 1.0 : double($b)}]

    set r [expr {(($r-1)*$s+1)*$l}]
    set g [expr {(($g-1)*$s+1)*$l}]
    set b [expr {(($b-1)*$s+1)*$l}]
    return [list $r $g $b]
 }

proc test {} {
    puts "get_svg white [[COLOR new 1.0 1.0 1.0 1.0] get_svg]"
    puts "test palette"
    PALETTE create pal -colorlist [list [COLOR new 0.0 0.0 0.0 0.0] 0.0 [COLOR new 1.0 0.0 0.0 1.0] 0.5 [COLOR new 1.0 1.0 1.0 1.0] 1.0]
    foreach i [drange 0.0 1.0 0.1] {
	puts "$i : color [[pal color $i] get_svg]"
    }
}
