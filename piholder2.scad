// Raspberry pi, smaller type, holder

// Main dimensions
inner_length = 65.5+7+2;
inner_width = 5;
wall_thickness = 2;
height = 25;
lip_height = 1.5;
lip_overhang = 1.5;

// Tolerances
clearance = 0.2;  // Gap between bracket and block
print_tolerance = 0.4;  // Manufacturing tolerance
epsilon = 0.01;  // Boolean operation margin

// Adjusted dimensions including clearance
adjusted_length = inner_length + clearance;
adjusted_width = inner_width + clearance;

// Main body of U bracket
module main_body() {
    difference() {
        // Outer shell
        cube([adjusted_length + 2*wall_thickness, 
              adjusted_width + 2*wall_thickness, 
              height]);
        
        // Inner cutout - slightly taller and deeper for clean boolean
        translate([wall_thickness, wall_thickness, -epsilon])
            cube([adjusted_length, 
                  adjusted_width, 
                  height + 2*epsilon]);
        
        // Front opening - slightly wider and taller for clean boolean
        translate([wall_thickness, -epsilon, -epsilon])
            cube([adjusted_length, 
                  wall_thickness + 2*epsilon, 
                  height + 2*epsilon]);
        
    }
}

// Single retention lip as a 2D profile to be extruded
module lip_profile() {
    polygon(points=[
        [0,0],                     // start at base
        [0,lip_height],            // up the wall
        [-lip_overhang,lip_height]          // angled retention feature
    ]);
}

// Both retention lips
module retention_lips() {
    // Left arm lip
    translate([wall_thickness , 
   0, height])
        rotate([0, 180, 0])
            linear_extrude(height=height)
                lip_profile();
    
    // Right arm lip
    translate([adjusted_length + wall_thickness, 0, 0])

            linear_extrude(height=height)
                lip_profile();
}

// Final assembly
module u_bracket() {
    union() {
        main_body();
        retention_lips();
    }
}

// Render the bracket
u_bracket();