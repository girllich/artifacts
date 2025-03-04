// Holder for vertically mounted standard US peghole board
// The direction of gravity is positive Y
// For 3d printing, direction of printing is positive Z upward
// Parameters
peghole_spacing = 25.4; // 1 inch in mm
// Maximum height from wall
torus_major_radius = 10; // Outer radius of torus for front row
torus_major_radius_back = torus_major_radius + peghole_spacing; // Back row 1 inch further
torus_minor_radius = 2.6; // Thickness of torus
closer_segment_angle = 60; // Degrees for each segment
further_segment_angle = 17; // Degrees for each segment
plate_thickness = 4;     // Increased for bit storage
plate_size = peghole_spacing * 2; // 2x2 inches
standoff_depth = 12; // Distance between pegboard and wall
total_height = plate_thickness + standoff_depth; 

// Create a torus segment with wall clearance
module torus_segment(major_r, minor_r, angle) {
    difference() {
        rotate_extrude(angle=angle, $fn=100)
            translate([major_r, 0, 0])
            circle(r=minor_r, $fn=50);
        
        // Cut off the top bit
        translate([0,standoff_depth,-minor_r*2])
            cube([plate_size, minor_r*4, plate_thickness]);
    }
}

module attachment() {
    difference() {
        // Original attachment cylinder
        rotate([0, 90, 90])  
        translate([8,0,torus_major_radius-torus_minor_radius])
        cylinder(r=5, h=peghole_spacing+torus_minor_radius*2, $fn=30);
        
        // Subtracting cube to make bottom flat
        translate([-10, torus_major_radius-torus_minor_radius*2, -22])
        cube([20, peghole_spacing+torus_minor_radius*4, 10]);
    }
}

// Create the base plate
module base_plate() {
    translate([-torus_minor_radius,torus_major_radius-torus_minor_radius,-plate_thickness])
    // Solid plate
    cube([torus_minor_radius*2, peghole_spacing+2*torus_minor_radius, plate_thickness]);
}

// Main assembly
union() {
    base_plate();
    attachment();
    // Front row torus segment (upper pegs)
    translate([0, 0, 0])
        rotate([0, 0, 90])  // Rotate to align with Y axis
        rotate([90, 0, 0])  // Standard rotation for torus
        torus_segment(torus_major_radius, torus_minor_radius, closer_segment_angle);
    
    // Back row torus segment (lower pegs)
    translate([0, 0, 0])
        rotate([0, 0, 90])  // Rotate to align with Y axis
        rotate([90, 0, 0])  // Standard rotation for torus
        torus_segment(torus_major_radius_back, torus_minor_radius, further_segment_angle);
}