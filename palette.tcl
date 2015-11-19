package require XOTcl; namespace import ::xotcl::*

if {[llength [Class info classchildren PALETTE]]} {
    return
}

Class PALETTE -parameter {indices}

PALETTE instproc init {{colors {0.0 {0.0 0.0 0.0 1.0} 1.0 {1.0 1.0 1.0 1.0}}} {
    
}
