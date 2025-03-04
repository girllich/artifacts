// Tapered hook for vertically mounted standard US peghole board
// The direction of gravity is positive Y
// For 3d printing, direction of printing is positive Z upward

// Mounting parameters
torus_major_radius = 10;    // Outer radius of torus
torus_minor_radius = 2.7;   // Thickness of torus
segment_angle = 60;         // Degrees for segment
standoff_depth = 12;        // Distance from wall to pegboard

// Hook parameters
hook_start_diameter = 12;   // Diameter at base of hook
hook_middle_diameter = 4;   // Diameter of main cylinder
hook_end_diameter = 5;      // Diameter at tip of hook
hook_length = 5;          // Total length of straight section
upper_transition_length = 10;  // Length of upper transition
lower_transition_length = 4;  // Length of lower transition
gravity_offset = 4;        // How far to offset the tip in gravity direction

// Calculate derived measurements
mounting_offset = torus_major_radius + hook_start_diameter/2 - torus_minor_radius+2;
start_to_middle_ratio = hook_middle_diameter/hook_start_diameter;
middle_to_end_ratio = hook_end_diameter/hook_middle_diameter;

// Create a torus segment for mounting
module torus_segment(major_r, minor_r, angle) {
    difference() {
        rotate_extrude(angle=angle, $fn=100)
            translate([major_r, 0, 0])
            circle(r=minor_r, $fn=50);
        
        // Cut off the top bit to make it fit into standoff
        translate([0, standoff_depth, -minor_r*2])
            cube([hook_body, minor_r*4, hook_body]);
    }
}

// Create the tapered hook body
module tapered_hook_body() {
    translate([0, mounting_offset, 0]) {
        // Upper transition section using linear extrusion
        translate([0, gravity_offset, -upper_transition_length]) {
            linear_extrude(
                height=upper_transition_length,
                scale=[hook_start_diameter/hook_middle_diameter, hook_start_diameter/hook_middle_diameter],
                $fn=50
            )
            translate([0, -gravity_offset/2, 0])
            circle(r=hook_middle_diameter/2);
            
            // Main hook shaft
            translate([0, -gravity_offset/2, -hook_length]) {
                // Base cylindrical section
                cylinder(
                    h=hook_length,
                    r=hook_middle_diameter/2,
                    $fn=50
                );
                
                // Lower transition section (hook tip)
                translate([0, hook_middle_diameter/2-0.4, -lower_transition_length]) {
                    linear_extrude(
                        height=lower_transition_length,
                        scale=[hook_middle_diameter/hook_end_diameter, hook_middle_diameter/hook_end_diameter],
                        $fn=50
                    )
                    translate([0, -gravity_offset/2, 0])
                    circle(r=hook_end_diameter/2);
                }
            }
        }
    }
}

// Main assembly
union() {
    // Torus mounting segment
    rotate([0, 0, 90])  // Rotate to align with Y axis
    rotate([90, 0, 0])  // Standard rotation for torus
    torus_segment(torus_major_radius, torus_minor_radius, segment_angle);
    
    // Hook body with taper
    tapered_hook_body();
}