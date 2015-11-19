set svgtemplate {<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="10cm" height="10cm" viewBox="%VIEWBOX%">
    %CONTENT%
</svg>
}

set polytemplate {
    <path style="fill:%FILLCOLOR%;fill-opacity:%FILLOPACITY%;stroke:%STROKECOLOR%;stroke-opacity:%STROKEOPACITY%" d="%POINTS%"/>
}

set circletemplate {
    <circle style="fill:%FILLCOLOR%;;fill-opacity:%FILLOPACITY%;stroke:%STROKECOLOR%;stroke-opacity:%STROKEOPACITY%" cx="%CX%" cy="%CY%" r="%RADIUS%"/>
}
