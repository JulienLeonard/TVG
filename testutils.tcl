source utils.tcl

proc assert= {label v1 v2} {
    if {[s= $v1 $v2]} {
	puts "OK: $label $v1"
    } else {
	puts "NOK: $label $v1 != $v2"
    }
}