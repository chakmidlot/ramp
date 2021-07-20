// ramp size
L = 860;
W = 45;
H = 25;

// printer bed size
MAX_X = 250;
MAX_Y = 200;

// radius of curvature
R = 3;

// distance between details
distance = 5;

module base() {   
    w = W - R*2;
    h = H - R*2;
    minkowski() {
        translate([-R, R, R])
        difference() {
            // ramp body
            rotate([0, -90, 0])
                linear_extrude(L-R*2)
                polygon([[0, 0], [0, w], [h, 0]]);

            // cut left
            translate([-W, 0, 0])
                rotate([0, -90, -90])
                linear_extrude(W)
                polygon([[0, W], [H, W], [H, 0]]);
            
            // cut right
            translate([-L + W + R*2, W, 0])
                rotate([0, -90, 90])
                linear_extrude(W)
                polygon([[0, W], [H, W], [H, 0]]);
        }
        
        sphere(R, $fn=30);
    }
}

lock_h = H / 4;
lock_wh = (W - 6) * (H - lock_h) / H / 2;
lock_wl = lock_wh * 0.8;
dh = 0.3;
dw = 0.2;

module lock_hole() {
    rotate([0, -90, 0])
        linear_extrude(8)
        polygon([
            [0, -lock_wl], [lock_h, -lock_wh], 
            [lock_h, lock_wh], [0, lock_wl]
        ]);
}

module lock_pin() {
    rotate([0, -90, 0])
        linear_extrude(6)
        polygon([
            [0, -lock_wl+dw], [lock_h-dh, -lock_wh+dw], 
            [lock_h-dh, lock_wh-dw], [0, lock_wl-dw]
        ]);
}

module ramp() {
    n_parts = ceil(L / (MAX_X - 10));
    part_lenght = L / n_parts;

    for (i = [0 : n_parts - 1]){
        difference() {
            translate([0, i * (W + distance), 0]) {
                intersection() {
                    translate([i * part_lenght, 0, 0])
                        base();
                    
                    translate([-part_lenght, 0, 0])
                        cube([part_lenght, W, H]);
                }
            }
            
            if (i > 0) {
                translate([1, i * (W + distance) + lock_wh + 4, 0])
                    lock_hole();
            }
        }
        
        if (i < n_parts - 1) {
            translate([-part_lenght, i * (W + distance) + lock_wh + 4, 0])
                lock_pin();
        }
    }
}

module test_lock() {
    intersection() {
        ramp();
        translate([-10, 50, 0]) cube([30, 40, 10]);
       
    }

    intersection() {
        translate([230, 0, 0])
            ramp();
        translate([0, 50, 0]) cube([25, 40, 10]);
    }
}

ramp();
// test_lock();