// Parameters
peghole_spacing = 25.4; // 1 inch in mm
plate_thickness = 12;     // Increased for bit storage
plate_size = peghole_spacing * 2; // 2x2 inches
torus_major_radius = 10; // Outer radius of torus for front row
torus_major_radius_back = torus_major_radius + peghole_spacing; // Back row 1 inch further
torus_minor_radius = 2.6; // Thickness of torus
closer_segment_angle = 60; // Degrees for each segment
further_segment_angle = 17; // Degrees for each segment

// Bit holder parameters
hex_width = 6.3;  // 4mm flat-to-flat hex (4.62mm corner-to-corner) + 2mm tolerance
hex_depth = 11;     // Slightly reduced for smaller bits
hex_spacing = 8;   // Reduced spacing for smaller bits
hex_spacing_y = 12;   // Reduced spacing for smaller bits
hex_margin = 5;    // Margin from edge of plate
hex_rotation = 30; // Rotation angle for hex holes

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

// Create a hexagonal hole
module hex_hole() {
    rotate([hex_rotation, 0, 0])  // Apply rotation around X axis for gravity support
    cylinder(r=hex_width/2, h=hex_depth + 2, $fn=6);  // Added extra length to ensure clean cuts
}

// Create the base plate with hex holes
module base_plate() {
    difference() {
        // Solid plate
        cube([plate_size, plate_size, plate_thickness]);
        
        // Array of hex holes on bottom
        translate([0, 6, 9])  // Moved holes up to leave more material at bottom
        mirror([0, 0, 1])
        translate([hex_margin, hex_margin, 0])
        for(x=[0:hex_spacing:plate_size-2*hex_margin]) {
            for(y=[0:hex_spacing_y:plate_size-hex_margin*2]) {
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