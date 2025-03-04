// Hook for vertically mounted standard US peghole board
// The direction of gravity is positive Y
// For 3d printing, direction of printing is positive Z upward
// Parameters
torus_major_radius = 10; // Outer radius of torus
torus_minor_radius = 2.7; // Thickness of torus
segment_angle = 60; // Degrees for segment

// Hook parameters
hook_diameter = 10; // Main cylinder diameter
hook_length = 16;    // Length of the vertical part
notch_diameter = 16.5;  // Diameter of the notch cut
notch_depth = 8;     // How deep the notch cuts into the cylinder
plate_thickness = 12;     // Increased for bit storage


// Create a torus segment
module torus_segment(major_r, minor_r, angle) {
    difference() {
        rotate_extrude(angle=angle, $fn=100)
            translate([major_r, 0, 0])
            circle(r=minor_r, $fn=50);
        // Cut off the top bit to make it fit into standoff
        
        translate([0,standoff_depth,-minor_r*2])
            cube([hook_body, minor_r*4, hook_body]);
    }
}

// Create the hook body
module hook_body() {
    translate([0,torus_major_radius+hook_diameter/2-torus_minor_radius,0])
    difference() {
        // Main cylinder
        translate([0,0,-hook_length])
        cylinder(h=hook_length, r=hook_diameter/2, $fn=50);
        
        // Notch cut (horizontal cylinder)
        translate([-hook_diameter, -notch_depth, -hook_length+notch_diameter/2])
            rotate([0, 90, 0])
            cylinder(h=hook_diameter*2, r=notch_diameter/2, $fn=50);
    }
}

// Main assembly
union() {
    // Torus mounting segment
    rotate([0, 0, 90])  // Rotate to align with Y axis
    rotate([90, 0, 0])  // Standard rotation for torus
    torus_segment(torus_major_radius, torus_minor_radius, segment_angle);
    
    // Hook body
    translate([0, 0, 0])
        hook_body();
}