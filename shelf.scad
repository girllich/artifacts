// Shelf for pegboard
// Parameters
peghole_spacing = 25.4; // 1 inch in mm
torus_major_radius = 10; // Outer radius of torus
torus_minor_radius = 2.6; // Thickness of torus/bar
closer_segment_angle = 60; // Degrees for each segment
bar_height = 30; // Height of connecting bar below torus segments
support_bar_length = 20; // Length of support bars
length = 3;
support_height = 5; // Height for middle supports
end_support_height = 15; // Height for end supports
further_segment_angle = 17; // Degrees for each segment
torus_major_radius_back = torus_major_radius + peghole_spacing; // Back row 1 inch further



// Create a torus segment with wall clearance
module torus_segment(major_r, minor_r, angle) {
    rotate_extrude(angle=angle, $fn=100)
        translate([major_r, 0, 0])
        circle(r=minor_r, $fn=50);
}

// Create connecting bar
module connecting_bar() {
    translate([-torus_minor_radius, torus_major_radius-torus_minor_radius, -bar_height])
        cube([peghole_spacing*length+torus_minor_radius*2, torus_minor_radius * 2, bar_height]);
}

// Create support bar
module support_bar(height) {
    cube([torus_minor_radius * 2, support_bar_length, height]);
}

// Main assembly
union() {
    // Position the entire assembly so 
    
    
    translate([0, 0, bar_height]) {
        // Front row torus segments (pegs)
        for(x=[0:peghole_spacing:peghole_spacing*length]) {
            translate([x, 0, 0])
                rotate([0, 0, 90])  // Rotate to align with Y axis
                rotate([90, 0, 0])  // Standard rotation for torus
                torus_segment(torus_major_radius, torus_minor_radius, closer_segment_angle);
        }
        
        // Connecting bar between pegs
        connecting_bar();
        
        // Support bars on opposite side
        for(x=[0:peghole_spacing:peghole_spacing*length]) {
            translate([x-torus_minor_radius,torus_major_radius-support_bar_length, -bar_height])
                support_bar(x == 0 || x == peghole_spacing*(length) ? end_support_height : support_height);
        }
    }
}