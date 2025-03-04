// Simplified pegboard hook with connecting bar
// Parameters
peghole_spacing = 25.4; // 1 inch in mm
torus_major_radius = 10; // Outer radius of torus
torus_minor_radius = 2.6; // Thickness of torus/bar
closer_segment_angle = 60; // Degrees for each segment
bar_height = 30; // Height of connecting bar below torus segments

// Tree cutout parameters
tree_height = bar_height * 0.95; // Tree height relative to bar height
tree_width = peghole_spacing * 0.9; // Tree width relative to peg spacing
trunk_width = tree_width * 0.2; // Trunk width relative to tree width
trunk_height = tree_height * 0.2; // Trunk height relative to tree height

// Create a torus segment with wall clearance
module torus_segment(major_r, minor_r, angle) {
    rotate_extrude(angle=angle, $fn=100)
        translate([major_r, 0, 0])
        circle(r=minor_r, $fn=50);
}

// Create 2D Christmas tree shape
module christmas_tree_2d() {
    // Tree triangular part
    polygon([
        [0, 0],  // Top point
        [-tree_width/2, -tree_height + trunk_height],  // Left bottom
        [-trunk_width/2, -tree_height + trunk_height],  // Left trunk top
        [-trunk_width/2, -tree_height],  // Left trunk bottom
        [trunk_width/2, -tree_height],   // Right trunk bottom
        [trunk_width/2, -tree_height + trunk_height],  // Right trunk top
        [tree_width/2, -tree_height + trunk_height],   // Right bottom
        [0, 0]   // Back to top
    ]);
}

// Create connecting bar with Christmas tree cutout
module connecting_bar() {
    difference() {
        // Main bar
        translate([-torus_minor_radius, torus_major_radius-torus_minor_radius, -bar_height])
            cube([peghole_spacing+torus_minor_radius*2, torus_minor_radius * 2, bar_height]);
        
        // Christmas tree cutout
        // Position it in the center of the bar
        translate([peghole_spacing/2, torus_minor_radius*4, -tree_height*0.1])
            // Rotate to align with correct axes
            rotate([90, 0, 0])
            // Extrude along Y axis
            linear_extrude(height=torus_minor_radius * 4, center=true)
                christmas_tree_2d();
    }
}

// Main assembly
union() {
    // Position the entire assembly so the bar is at z=0 for printing
    translate([0, 0, bar_height]) {
        // Front row torus segments (pegs)
        for(x=[0:peghole_spacing:peghole_spacing]) {
            translate([x, 0, 0])
                rotate([0, 0, 90])  // Rotate to align with Y axis
                rotate([90, 0, 0])  // Standard rotation for torus
                torus_segment(torus_major_radius, torus_minor_radius, closer_segment_angle);
        }
        
        // Connecting bar between pegs
        connecting_bar();
    }
}