// Simplified pegboard hook with connecting bar and pen storage
// Parameters
peghole_spacing = 25.4; // 1 inch in mm
torus_major_radius = 10; // Outer radius of torus
torus_minor_radius = 2.6; // Thickness of torus/bar
closer_segment_angle = 60; // Degrees for each segment
bar_height = 30; // Height of connecting bar below torus segments
pen_diameter = 60; // Diameter for pen storage
pen_depth = 4; // Depth of the pen notch
length = 3;

// Create a torus segment with wall clearance
module torus_segment(major_r, minor_r, angle) {
    rotate_extrude(angle=angle, $fn=100)
        translate([major_r, 0, 0])
        circle(r=minor_r, $fn=50);
}

// Create connecting bar with pen notch
module connecting_bar() {
    difference() {
        // Main bar
        translate([-torus_minor_radius, torus_major_radius-torus_minor_radius, -bar_height])
            cube([peghole_spacing*length+torus_minor_radius*2, torus_minor_radius * 2, bar_height]);
        
        // Pen storage cutout
        translate([peghole_spacing/2, torus_major_radius-pen_diameter*0.5, -bar_height/2])
            rotate([0, 90, 0])
            cylinder(h=peghole_spacing*(length+1)*2+torus_minor_radius, r=pen_diameter/2, center=true, $fn=(pen_diameter*2));
    }
}

// Main assembly
union() {
    // Position the entire assembly so the bar is at z=0 for printing
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
    }
}