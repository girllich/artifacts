// Parameters
// Pegboard microscope bar base
peghole_spacing = 25.4; // 1 inch in mm
plate_thickness = 60;     // Reduced thickness since we don't need bit storage
torus_major_radius = 10; // Outer radius of torus for front row
torus_major_radius_back = torus_major_radius + peghole_spacing; // Back row 1 inch further
torus_minor_radius = 2.6; // Thickness of torus
plate_size = peghole_spacing*2 + torus_minor_radius*2; // 2x2 inches
closer_segment_angle = 50; // Degrees for each segment
further_segment_angle = 17; // Degrees for each segment
bar_diameter = 22; // Diameter of the vertical bar


// Create a torus segment
module torus_segment(major_r, minor_r, angle) {
        rotate_extrude(angle=angle, $fn=100)
            translate([major_r, 0, 0])
            circle(r=minor_r, $fn=50);
   
}



module torus_with_cone(major_r, minor_r, angle, cone_height) {
    // Original torus segment
    torus_segment(major_r, minor_r, angle);
    
    // Calculate points for the cone
    // The cone needs to be positioned at the end of the torus segment
    angle_rad = angle * PI / 180;  // Convert angle to radians
    x = major_r * cos(angle);      // X position of the end of the torus
    y = major_r * sin(angle);      // Y position of the end of the torus
    
    // Position and create the cone
    translate([x, y, 0])
        rotate([-90, 0, angle])
            cylinder(h=cone_height, r1=minor_r, r2=0, $fn=50);
}

// Create a cylinder with one face cut off
module cut_cylinder(radius, height) {
    difference() {
        cylinder(r=radius, h=height, $fn=100);
        // Cut off one face
        translate([-radius, -radius*1.75, -1])
            cube([radius * 2, radius, height+2]);
    }
}

module water_droplet(height=10, radius=11.5, point_height=20) {
    // Create the 2D shape
    
    rotate([-90,0,0]){
    linear_extrude(height=height)
    hull() {
        // Circular part
        circle(r=radius, $fn=100);
        
        // Point (using a very small circle)
        translate([0, -point_height, 0])
        circle(r=0.1, $fn=20);
    }}
}


// Create the triangular prism base
module base_plate() {
    height = plate_size;  // Height along Y axis
    base_width = plate_size;  // Width of the triangle base
    depth = plate_thickness;  // Depth/thickness of the prism
    
    // Translate to align with original positioning
    translate([-base_width/2-torus_minor_radius, torus_major_radius+base_width-torus_minor_radius, 0])
        // Rotate to align along Y axis
        rotate([90, 0, 0])
        // Create the triangular prism
        linear_extrude(height=height)
            polygon(points=[
                [0, 0],
                [base_width, 0],
                [base_width/2+bar_diameter/2*1.4, -depth],
                [base_width/2-bar_diameter/2*1.4, -depth]
            ]);
}

// Main assembly
union() {
    difference(){
    base_plate();
    
    translate([-torus_minor_radius,0,-plate_thickness+16]){
water_droplet(peghole_spacing*2);
    }}
    
    
    // Front row torus segments (upper pegs)
       for(y=[0:peghole_spacing/2:plate_size/2]) {
    for(x=[0:peghole_spacing:plate_size]) {
        translate([x - plate_size/2, y, 0])
            rotate([0, 0, 90])  // Rotate to align with Y axis
            rotate([90, 0, 0])  // Standard rotation for torus
            torus_with_cone(torus_major_radius+y, torus_minor_radius, closer_segment_angle*torus_major_radius/(torus_major_radius+y),2.4*torus_major_radius/(torus_major_radius+y));
    }
}
   
}