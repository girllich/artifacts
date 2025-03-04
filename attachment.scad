// T-slot Slide Nut Extension Parameters
neck_width = 8;    // Width of the neck (mm)
neck_height = 4;   // Height of the neck (mm)
t_width = 20-1.5;      // Total width of the T (mm)
tail_height = 2;   // Height the tails extend upward (mm)
total_height = 6;  // Total height of the part (mm)
length = 10;       // Length of the extension along the slot (mm)
neck_extension = 2; // Additional height for the neck extension
e = 0.01;
tail_width = 2;
// Hole and nut parameters
m4_diameter = 4.3;  // Slightly larger for 3D printing tolerances
m4_hole_depth = 9.5;  // Depth of the M4 hole (mm)
m4_nut_width = 7.5;   // Width across flats for an M4 nut
m4_nut_height = 4.2; // Height of an M4 nut
m4_nut_insertion_width = m4_nut_width; // Width for insertion
m4_nut_insertion_height = m4_nut_height; // Add some clearance for insertion
// Calculate derived dimensions
wing_width = (t_width - neck_width) / 2 - tail_width;  // Width of each "wing" of the T
bottom_extension = 4.3;
bottom_ext_w = 13;
// Create a teardrop shape for better printability along Y axis
module teardrop(d, h) {
    union() {
        // Main cylinder part
        cylinder(d=d, h=h, $fn=32);

        // Triangular top for printability
        translate([0, -3, 0])
            rotate([0, 0, 45])  // Rotate to align with print orientation
            linear_extrude(height=h)
                polygon(points=[[0,0], [d/2,0], [0,d/2]]);
    }
}
module t_slot_extension() {
    difference() {
        union() {
            // Main body - a cuboid with reduced height
            cube([t_width, length, total_height - neck_extension]);

            // Add the extension to the neck
            translate([(t_width - neck_width)/2, 0, total_height - neck_extension])
                cube([neck_width, length, neck_extension]);

            // Bottom extension
            translate([(t_width - bottom_ext_w)/2, 0, -bottom_extension])
                cube([bottom_ext_w, length, bottom_extension]);
        }

        // Cut out the undercuts on both sides
        translate([tail_width, -e, neck_height+e - neck_extension])
            cube([wing_width, length+2*e, tail_height]);

        translate([t_width - wing_width-tail_width, -e, neck_height+e - neck_extension])
            cube([wing_width, length+2*e, tail_height]);

        // M4 teardrop hole from the top center
        translate([t_width/2, length/2, total_height - m4_hole_depth])
            rotate([0, 0, 0])  // Rotate for Y-axis printing orientation
            teardrop(d=m4_diameter, h=m4_hole_depth+e);

        // Nut trap - hexagonal cutout
        translate([t_width/2, length/2, total_height - m4_hole_depth])
            rotate([0, 0, 30])  // Rotate for better printing of the hexagon
            cylinder(h=m4_nut_height, d=m4_nut_width/cos(30), $fn=6);  // Hexagon for the nut

        // Rectangular slot for nut insertion from the side
        translate([t_width/2 - m4_nut_insertion_width/2, -e, total_height - m4_hole_depth])
            cube([m4_nut_insertion_width, length/2 + e, m4_nut_insertion_height]);
    }
}
t_slot_extension();