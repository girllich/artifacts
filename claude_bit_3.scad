// Hex bit holder for vertically mounted standard US peghole board
// The direction of gravity is positive Y
// For 3d printing, direction of printing is positive Z upward
// Parameters
peghole_spacing = 25.4; // 1 inch in mm
plate_thickness = 12;     // Increased for bit storage
plate_size = peghole_spacing * 2; // 2x2 inches
standoff_depth = 12; // Distance between pegboard and wall
total_height = plate_thickness + standoff_depth; // Maximum height from wall

torus_major_radius = 10; // Outer radius of torus for front row
torus_major_radius_back = torus_major_radius + peghole_spacing; // Back row 1 inch further
torus_minor_radius = 2.6; // Thickness of torus
closer_segment_angle = 60; // Degrees for each segment
further_segment_angle = 17; // Degrees for each segment

// Bit holder parameters
hex_width = 9.1; //.34;  // 1/4" hex bit width (7.34mm) + 2mm tolerance for 3D printing
hex_depth = 12;     // Increased depth of hex holes
hex_spacing = 13;  // Space between hex holes
hex_spacing_b = 15;  // Space between hex holes

hex_margin = 5;    // Margin from edge of plate
hex_rotation = 30; // Rotation angle for hex holes

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

// Create a hexagonal hole
module hex_hole() {
    rotate([hex_rotation, 0, 0])  // Apply rotation around Y axis
    cylinder(r=hex_width/2, h=hex_depth + 2, $fn=6);  // Added extra length to ensure clean cuts
}

// Create the base plate with hex holes
module base_plate() {
    difference() {
        // Solid plate
        cube([plate_size, plate_size, plate_thickness]);
        
        // Array of hex holes on bottom
        translate([1, 4, 9])  // Moved holes up to leave more material at bottom
        mirror([0, 0, 1])
        translate([hex_margin, hex_margin+5, 0])
        for(x=[0:hex_spacing:plate_size-2*hex_margin]) {
            for(y=[2:hex_spacing_b:plate_size-2*hex_margin]) {
                translate([x, y, -1])
                    hex_hole();
            }
        }
    }
}

// Main assembly
union() {
    base_plate();
    
    // Front row torus segments (upper pegs)
    for(x=[peghole_spacing/2:peghole_spacing:plate_size-5]) {
        translate([x, 0, plate_thickness])
            rotate([0, 0, 90])  // Rotate to align with Y axis
            rotate([90, 0, 0])  // Standard rotation for torus
            torus_segment(torus_major_radius, torus_minor_radius, closer_segment_angle);
    }
    
    // Back row torus segments (lower pegs)
    for(x=[peghole_spacing/2:peghole_spacing:plate_size-5]) {
        translate([x, 0, plate_thickness])
            rotate([0, 0, 90])  // Rotate to align with Y axis
            rotate([90, 0, 0])  // Standard rotation for torus
            torus_segment(torus_major_radius_back, torus_minor_radius, further_segment_angle);
    }
}