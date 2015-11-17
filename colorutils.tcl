
proc randcolor {{a 1.0}} {
    return [list [int [drand 0.0 255.0]] [int [drand 0.0 255.0]] [int [drand 0.0 255.0]] $a] 
}
