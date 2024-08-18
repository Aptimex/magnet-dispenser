
/* [Magnets] */
magnet_diameter = 8;
magnet_thickness = 2;
label = "8mm X 2mm";
textSize = 8;

/* [Basic] */
bodyLen = 75;
bodyWall = 1.2;
armThick = 2.4;
maxArmLen = 72.2;
hingeReinforcement = 15;

/* [Advanced] */
tube_tolerance = 0.5;
endCapThickness = 0.8;
tabBodyGap = 4;


module null() {
    // Stop processing customizer vars
}
$fn = 100 + 0;
e = 0.001 + 0;


magThick = magnet_thickness;
slotW = magnet_diameter + 1;
slotD = magThick + 0.6;
tubeDia = magnet_diameter+tube_tolerance;
tubeLen = bodyLen - magThick -endCapThickness - slotD;
bodySide = tubeDia + bodyWall*2;


//armLen = tubeLen + slotD;
armLen = min(tubeLen + slotD, maxArmLen);
arm_rotation = asin((bodySide+tabBodyGap)/armLen);

module body() {
    difference() {
        //body
        cube(size=[bodyLen, bodySide, bodySide], center=false);
        
        //Tube cutout
        translate([magThick+endCapThickness+slotD-e, bodySide/2, bodySide/2]) 
        rotate([0, 90, 0]) 
        cylinder(d=tubeDia, h=tubeLen +2*e, center=false);
        
        n = (bodySide-tubeDia)/2;
        /*
        //squared cutout cutout for simpler printing
        color([0,1,0])
        translate([magThick+endCapThickness+slotD-e, n, tubeDia+n]) 
        rotate([0, 90, 0]) 
        cube(size=[tubeDia, tubeDia, tubeLen+2*e], center=false); //change first tubeDia to be /2 for a top-only square
        */
        
        //Dispenser slot
        translate([endCapThickness+magThick, -e, (bodySide-slotW)/2]) 
        cube(size=[slotD, bodySide + 2*e, slotW], center=false);
        
        //magnet hole on end
        translate([-e, bodySide/2, bodySide/2]) 
        rotate([0, 90, 0]) 
        cylinder(d=tubeDia, h=magThick+e, center=false);
        
        /*
        //Square cuttout on end hole
        color([0,1,0])
        translate([-e, n, tubeDia+n]) 
        rotate([0, 90, 0]) 
        cube(size=[tubeDia, tubeDia, magThick + 2*e], center=false); //change first tubeDia to be /2 for a top-only square
        */
    }
    
    //tab sled
    guideDem = magThick+endCapThickness;
    translate([guideDem, bodySide, 0])
    rotate([0, 0, 90]) 
    mirror([0, 0, 1])
    rotate([0, 90, 0]) 
    difference() {
        tPrism(bodySide, guideDem, guideDem*2);
        
        //trim off end of prism
        translate([-e, e, tabBodyGap]) 
        cube(size=[bodySide + 2*e, guideDem, guideDem*2], center=false);
    }
    
    
    
}

module arm() {
    
    //arm
    difference() {
        cube(size=[armLen, armThick, bodySide], center=false);
        
        translate([armLen, 0, -e]) 
        rotate([0, 0, arm_rotation]) 
        cube(size=[armThick*2, armThick*2, bodySide*2], center=false);
        
        //Text
        //translate([armLen-1, armThick-0.6+e, (bodySide-textSize)/2]) 
        //rotate([90, 0, 180])
        translate([1, armThick-0.6+e, textSize + (bodySide-textSize)/2]) 
        rotate([90, 180, 180])
        linear_extrude(0.6)
        text(label, size=textSize, font="Ariel", halign="left", valign="baseline");
    }
    
    
    
    
    
    //tab
    tabTolerance = 2;
    //tabThick = max(slotD - 1, 0.8);
    tabThick = magThick;
    tabOffsetV = (bodySide-slotW+tabTolerance)/2;
    translate([0, -bodySide+(tabThick/2), tabOffsetV]) 
    cube(size=[tabThick, bodySide-(tabThick/2), slotW - tabTolerance], center=false);
    
    //round off tab end
    translate([tabThick/2, -bodySide+(tabThick/2), tabOffsetV]) 
    cylinder(d=tabThick, h=(slotW - tabTolerance), center=false);
    
    
    //Hinge reinforcement values
    //hingeReinforcement = max(15, bodyLen-60);
    hingeY = sin(arm_rotation+1)*hingeReinforcement + .1;
    
    //joint reinforcement
    translate([armLen-hingeReinforcement, -hingeY, 0])
    mirror([0, 0, 1])
    rotate([0, 90, 0]) 
    tPrism(bodySide, hingeY, hingeReinforcement);
}


body();


//rotate_about_pt(-arm_rotation, 0, [bodyLen, bodySide, 0])
//translate([bodyLen - armLen, bodySide, 0]) 
rotate_about_pt(-arm_rotation, 0, [magThick+endCapThickness+armLen, bodySide, 0])
translate([magThick+endCapThickness, bodySide, 0]) 
color([1, 0, 0])
arm();


// https://stackoverflow.com/questions/45826208/openscad-rotating-around-a-particular-point
module rotate_about_pt(z, y, pt) {
    translate(pt)
        rotate([0, y, z]) // CHANGE HERE
            translate(-pt)
                children();   
}

//Generate triangular prism (90 deg)
module tPrism(d, w, h){
       polyhedron(
           points=[[0,0,0], [d,0,0], [d,w,0], [0,w,0], [0,w,h], [d,w,h]],
           faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
       );
}
