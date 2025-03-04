// Parameters
peghole_spacing = 25.4; // 1 inch in mm
plate_thickness = 9;     // Reduced thickness since we don't need bit storage
torus_major_radius = 10; // Outer radius of torus for front row
torus_major_radius_back = torus_major_radius + peghole_spacing; // Back row 1 inch further
torus_minor_radius = 2.6; // Thickness of torus
plate_size = peghole_spacing + torus_minor_radius*2; // 2x2 inches
closer_segment_angle = 60; // Degrees for each segment
further_segment_angle = 17; // Degrees for each segment
bar_diameter = 22; // Diameter of the vertical bar
hole_diameter = 15; // Diameter for the top holes

// Create a torus segment
module torus_segment(major_r, minor_r, angle) {
    difference() {
        rotate_extrude(angle=angle, $fn=100)
            translate([major_r, 0, 0])
            circle(r=minor_r, $fn=50);
        // Cut off the back half to make it printable
        translate([-major_r*2, -major_r*2, -minor_r])
            cube([major_r*4, major_r*2, minor_r*2]);
    }
}

// Create the base plate with vertical bar hole and top holes
module base_plate() {
    difference() {
        // Solid plate
        translate([-torus_minor_radius,torus_major_radius-torus_minor_radius,0])
            cube([plate_size, plate_size, plate_thickness]);
        
        // Array of holes along y-axis
        for(y=[0:1:5]) {
            translate([y+torus_minor_radius+hole_diameter/2, torus_major_radius, plate_thickness])  // Move to center of plate thickness
                rotate([90, 90, 0])  // Rotate to align with y-axis
                cylinder(h=plate_size*2, d=hole_diameter, $fn=30, center=true);
        }
        
        // Vertical bar hole
        // (left empty in original code)
    }
}

// Main assembly
union() {
    base_plate();
    // Front row torus segments (upper pegs)
    for(x=[0:peghole_spacing:plate_size]) {
        translate([x, 0, plate_thickness])
            rotate([0, 0, 90])  // Rotate to align with Y axis
            rotate([90, 0, 0])  // Standard rotation for torus
            torus_segment(torus_major_radius, torus_minor_radius, closer_segment_angle);
    }
    // Back row torus segments (lower pegs)
    for(x=[0:peghole_spacing:plate_size]) {
        translate([x, 0, plate_thickness])
            rotate([0, 0, 90])  // Rotate to align with Y axis
            rotate([90, 0, 0])  // Standard rotation for torus
            torus_segment(torus_major_radius_back, torus_minor_radius, further_segment_angle);
    }
}