// Cable hole rim for 4cm diameter hole with 2cm wide rim
// Designed to cover uneven hole edges with beveled outer edge and inner lip

// Include threading library
include <threads.scad>

// Higher resolution for smoother cylinders
$fn = 60;

// Parameters
hole_diameter = 40;      // 4cm hole diameter
rim_width = 15;          // 2cm rim width
rim_thickness = 1.5;       // Thickness to match desk backing
bevel_size = 1;          // Size of the bevel on outer edge
lip_height = 8;          // 8mm height of inner lip that goes into hole
lip_thickness = 3;       // 3mm thickness of the lip wall
thread_pitch = 2;        // Thread pitch (distance between threads)
thread_diameter = 39;    // External thread diameter (close to hole_diameter for tight fit)

// Calculated values
outer_diameter = hole_diameter + (rim_width * 2);
inner_radius = hole_diameter / 2;
outer_radius = outer_diameter / 2;
lip_radius = inner_radius - lip_thickness;
rotate([180,0,0]){
difference() {
    union() {
        // Main rim body with beveled edge
        hull() {
            // Top surface (full size)
            translate([0, 0, rim_thickness - 0.1])
                cylinder(h = 0.1, r = outer_radius - bevel_size, center = false);
            
            // Bottom surface (full size) 
            cylinder(h = 0.1, r = outer_radius, center = false);
        }
        
        // Add threaded inner lip that goes into the hole
        translate([0, 0, -lip_height]) {
            // Use MetricBolt approach - just the threaded part without the head
            translate([0,0,0])
                ScrewThread(thread_diameter, lip_height+0.01, tolerance=0.4, tooth_angle=45);
        }
    }
    
    // Hollow out the cable passage through both rim and threaded lip
    // Use smaller radius to preserve thread structure
    translate([0, 0, -lip_height-0.2])
        cylinder(h = lip_height + rim_thickness + 0.4, r = 15, center = false);
}

// Matching nut with rim (upside down for printability)
translate([71, 0, 0]) rotate([0, 0, 0]) {
    difference() {
        union() {
            // Nut rim body with beveled edge
            hull() {
                // Top surface (smaller due to bevel)
                translate([0, 0, rim_thickness - 0.1])
                    cylinder(h = 0.1, r = outer_radius - bevel_size, center = false);
                
                // Bottom surface (full size) 
                cylinder(h = 0.1, r = outer_radius, center = false);
            }
            
            // Threaded nut body extending down
            translate([0, 0, -lip_height])
                cylinder(h = lip_height, r = thread_diameter/2 + 2, center = false);
        }
        
        // Remove internal threads - subtract same ScrewThread as the rim
        translate([0, 0, -lip_height-5])
            ScrewThread(thread_diameter+0.6, lip_height + 0.2+5, tolerance=0.4, tooth_angle=45);
        
        // Cable passage
        translate([0, 0, -lip_height-0.2])
            cylinder(h = lip_height + rim_thickness + 0.4, r = 15, center = false);
    }
}
}