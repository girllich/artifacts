#!/usr/bin/env -S uv run --with pillow
"""
3D Artifacts Renderer - Pipe-based Version

Renders all OpenSCAD files from 9 different angles (6 orthogonal + 3 isometric) 
and creates a 3x3 grid layout for each artifact using pipes to minimize disk writes.

Usage: ./build_renders.py
"""

import subprocess
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import io
import concurrent.futures

# Camera positions for rendering
CAMERA_POSITIONS = [
    # Top row: Front, Top, Right
    {"rot": [90, 0, 0], "name": "front"},
    {"rot": [0, 0, 0], "name": "top"}, 
    {"rot": [90, 0, 90], "name": "right"},
    
    # Middle row: Left, Isometric 1, Back  
    {"rot": [90, 0, -90], "name": "left"},
    {"rot": [60, 0, 45], "name": "iso1"},
    {"rot": [90, 0, 180], "name": "back"},
    
    # Bottom row: Bottom, Isometric 2, Isometric 3
    {"rot": [180, 0, 0], "name": "bottom"},
    {"rot": [60, 0, 135], "name": "iso2"}, 
    {"rot": [60, 0, 225], "name": "iso3"}
]

def render_scad_to_bytes(scad_file, camera_pos, image_size=400):
    """Render a single OpenSCAD file from one camera position directly to bytes"""
    cmd = [
        "openscad",
        "--render",
        "--imgsize", f"{image_size},{image_size}",
        "--camera", f"0,0,0,{camera_pos['rot'][0]},{camera_pos['rot'][1]},{camera_pos['rot'][2]},100",
        "--colorscheme", "Tomorrow Night",
        "--projection", "o",  # Orthographic projection instead of perspective
        "--autocenter",       # Auto-center the model in the view
        "--viewall",          # Auto-zoom to fit the entire model
        "--export-format", "png",
        "-o", "/dev/stdout",  # Output to stdout
        str(scad_file)
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, timeout=1800)
        if result.returncode == 0 and result.stdout:
            return result.stdout, camera_pos['name']
        else:
            print(f"Error rendering {scad_file.name} from {camera_pos['name']}: {result.stderr.decode() if result.stderr else 'Unknown error'}")
            return None, camera_pos['name']
    except subprocess.TimeoutExpired:
        print(f"Timeout rendering {scad_file.name} from {camera_pos['name']}")
        return None, camera_pos['name']
    except Exception as e:
        print(f"Exception rendering {scad_file.name} from {camera_pos['name']}: {e}")
        return None, camera_pos['name']

def create_grid_from_bytes(image_bytes_list, output_path, grid_size=3, image_size=400, title=""):
    """Create a 3x3 grid from 9 rendered images in memory"""
    grid_width = grid_size * image_size
    grid_height = grid_size * image_size + 50  # Extra space for title
    
    grid_img = Image.new('RGB', (grid_width, grid_height), color='white')
    
    # Add title
    if title:
        draw = ImageDraw.Draw(grid_img)
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 24)
        except:
            font = ImageFont.load_default()
        
        text_bbox = draw.textbbox((0, 0), title, font=font)
        text_width = text_bbox[2] - text_bbox[0]
        text_x = (grid_width - text_width) // 2
        draw.text((text_x, 10), title, fill='black', font=font)
    
    # Place images in grid
    for i, (img_bytes, view_name) in enumerate(image_bytes_list):
        if img_bytes:
            try:
                img = Image.open(io.BytesIO(img_bytes))
                img = img.resize((image_size, image_size), Image.Resampling.LANCZOS)
                
                row = i // grid_size
                col = i % grid_size
                x = col * image_size
                y = row * image_size + 50  # Offset for title
                
                grid_img.paste(img, (x, y))
                
                # Add view label
                draw = ImageDraw.Draw(grid_img)
                try:
                    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 16)
                except:
                    font = ImageFont.load_default()
                
                draw.text((x + 5, y + 5), view_name, fill='white', font=font)
                
            except Exception as e:
                print(f"Error processing image bytes for view {view_name}: {e}")
                # Fill with placeholder
                draw = ImageDraw.Draw(grid_img)
                row = i // grid_size
                col = i % grid_size
                x = col * image_size
                y = row * image_size + 50
                
                draw.rectangle([x, y, x + image_size, y + image_size], fill='lightgray', outline='gray')
                draw.text((x + image_size//2 - 30, y + image_size//2), "Error", fill='black')
        else:
            # Fill with placeholder for missing images
            draw = ImageDraw.Draw(grid_img)
            row = i // grid_size
            col = i % grid_size
            x = col * image_size
            y = row * image_size + 50
            
            draw.rectangle([x, y, x + image_size, y + image_size], fill='lightgray', outline='gray')
            draw.text((x + image_size//2 - 30, y + image_size//2), "Missing", fill='black')
    
    grid_img.save(output_path, quality=95)
    print(f"Created grid: {output_path}")

def render_stl(scad_file, output_dir):
    """Render SCAD file to STL"""
    stl_output = output_dir / f"{scad_file.stem}.stl"
    
    cmd = [
        "openscad",
        "--render",
        "-o", str(stl_output),
        str(scad_file)
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, timeout=1800)
        if result.returncode == 0:
            print(f"  Created STL: {stl_output.name}")
            return True
        else:
            print(f"  STL render failed: {result.stderr.decode() if result.stderr else 'Unknown error'}")
            return False
    except subprocess.TimeoutExpired:
        print(f"  STL render timeout")
        return False
    except Exception as e:
        print(f"  STL render exception: {e}")
        return False

def process_scad_file(scad_file, output_dir):
    """Process a single SCAD file - render all views and create grid in memory, plus STL"""
    print(f"Processing {scad_file.name}...")
    
    # Render STL file
    render_stl(scad_file, output_dir)
    
    # Render all 9 views to bytes in parallel
    rendered_images = []
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
        futures = {executor.submit(render_scad_to_bytes, scad_file, cam_pos): cam_pos for cam_pos in CAMERA_POSITIONS}
        
        # Collect results in the order of CAMERA_POSITIONS
        results = {}
        for future in concurrent.futures.as_completed(futures):
            cam_pos = futures[future]
            try:
                img_bytes, view_name = future.result()
                results[view_name] = img_bytes
            except Exception as e:
                print(f"Exception in thread for {cam_pos['name']}: {e}")
                results[cam_pos['name']] = None
    
    # Order results to match CAMERA_POSITIONS
    ordered_results = []
    for cam_pos in CAMERA_POSITIONS:
        img_bytes = results.get(cam_pos['name'])
        ordered_results.append((img_bytes, cam_pos['name']))
    
    # Create grid image directly from bytes
    grid_output = output_dir / f"{scad_file.stem}_grid.png"
    create_grid_from_bytes(ordered_results, grid_output, title=scad_file.stem)

def main():
    """Main function to process all SCAD files"""
    current_dir = Path.cwd()
    output_dir = current_dir / "renders"
    output_dir.mkdir(exist_ok=True)
    
    # Find all SCAD files
    scad_files = list(current_dir.glob("*.scad"))
    
    if not scad_files:
        print("No SCAD files found in current directory")
        return 1
    
    print(f"Found {len(scad_files)} SCAD files")
    
    # Process each SCAD file
    for scad_file in scad_files:
        try:
            process_scad_file(scad_file, output_dir)
        except Exception as e:
            print(f"Error processing {scad_file.name}: {e}")
            continue
    
    print(f"All renders saved to: {output_dir}")
    return 0

if __name__ == "__main__":
    sys.exit(main())