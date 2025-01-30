#!/usr/bin/env python3
import geocoder
from astral import LocationInfo, Observer
from astral.sun import elevation
from datetime import datetime
import subprocess
import os
import sys

# --- Configuration ---
AM_IMAGES = {
    (-90, -10): "~/Pictures/cyberpunk-01/cyberpunk-01-10.jpg",
    (-10,-5): "~/Pictures/cyberpunk-01/cyberpunk-01-11.jpg",
    (-5, 0): "~/Pictures/cyberpunk-01/cyberpunk-01-12.jpg",  
    (0, 5): "~/Pictures/cyberpunk-01/cyberpunk-01-13.jpg",  
    (5, 10): "~/Pictures/cyberpunk-01/cyberpunk-01-14.jpg",  
    (10, 20): "~/Pictures/cyberpunk-01/cyberpunk-01-15.jpg",  
    (50, 70): "~/Pictures/cyberpunk-01/cyberpunk-01-1.jpg",
    (70, 90): "~/Pictures/cyberpunk-01/cyberpunk-01-1.jpg",
}

PM_IMAGES = {
    (70, 90): "~/Pictures/cyberpunk-01/cyberpunk-01-2.jpg",
    (50, 70): "~/Pictures/cyberpunk-01/cyberpunk-01-3.jpg",
    (30, 50): "~/Pictures/cyberpunk-01/cyberpunk-01-4.jpg",
    (20, 30): "~/Pictures/cyberpunk-01/cyberpunk-01-5.jpg",
    (10, 20): "~/Pictures/cyberpunk-01/cyberpunk-01-6.jpg",
    (0, 10): "~/Pictures/cyberpunk-01/cyberpunk-01-7.jpg",
    (-10, 0): "~/Pictures/cyberpunk-01/cyberpunk-01-8.jpg",
    (-90, -10): "~/Pictures/cyberpunk-01/cyberpunk-01-9.jpg",
}



# --- Functions ---
def get_current_location():
    """Gets the current location using geocoder."""
    g = geocoder.ip('me')
    if g.ok:
        return g.latlng
    else:
        print("Error getting location.")
        return None

def get_sun_angle(latitude, longitude):
    """Gets the current sun's altitude using astral."""
    o = Observer(latitude=latitude, longitude=longitude)
    return elevation(o, dateandtime=datetime.now())
    # We're interested in the sun's elevation (altitude)
    
def set_wallpaper(image_path):
    """Sets the wallpaper using hyprctl."""
    image_path = os.path.expanduser(image_path)  # Expand user path if needed
    # print(f"Setting wallpaper to: {image_path}")  # Debugging line
    try:
        loaded = subprocess.run(["hyprctl", "hyprpaper", "listloaded", image_path], capture_output=True, check=True)
        subprocess.run(["hyprctl", "hyprpaper", "preload", image_path], check=True)
        subprocess.run(["hyprctl", "hyprpaper", "wallpaper", f",{image_path}"], check=True)
        subprocess.run(["hyprctl", "hyprpaper", "unload", loaded.stdout], check=True)
        if os.path.exists("/tmp/current_wallpaper.jpg"):
            os.remove("/tmp/current_wallpaper.jpg")
        os.symlink(image_path, "/tmp/current_wallpaper.jpg")  # Create a symlink to the current wallpaper
        print(f"Wallpaper set to: {image_path}")
    except subprocess.CalledProcessError as e:
        print(f"Error setting wallpaper: {e}")
    except FileNotFoundError as e:
        print(f"Error: hyprctl or hyprpaper not found. Make sure they are in your PATH. {e}")

def find_matching_image(sun_angle):
    """Finds the best matching image based on the current sun angle."""
    best_match = None
    smallest_diff = float('inf')
    # if time is between 12 AM and 12 PM, use AM images, otherwise use PM images
    IMAGE_MAPPING = AM_IMAGES if datetime.now().hour < 12 else PM_IMAGES

    for angle_range, image_path in IMAGE_MAPPING.items():
        lower_bound, upper_bound = angle_range
        if lower_bound <= sun_angle <= upper_bound:
            return image_path  # Exact match found

        # If no exact match, find the closest range
        midpoint = (lower_bound + upper_bound) / 2
        diff = abs(sun_angle - midpoint)
        if diff < smallest_diff:
            smallest_diff = diff
            best_match = image_path

    return best_match

# --- Main Script ---
if __name__ == "__main__":
    location = get_current_location()
    if location:
        with open('location.txt', 'w') as f:
            f.write(f"{location[0]},{location[1]}")
    if location is None:
        if os.path.exists('location.txt'):
            with open('location.txt', 'r') as f:
                location_str = f.read().strip()
            latitude, longitude = map(float, location_str.split(','))
        else:
            print("Location not available and no previous location stored.")
            sys.exit(1)
    latitude, longitude = location
    current_sun_angle = get_sun_angle(latitude, longitude)
    print(f"Current sun angle: {current_sun_angle:.2f} degrees")

    matching_image = find_matching_image(current_sun_angle)

    if matching_image:
        set_wallpaper(matching_image)
    else:
        print("No matching wallpaper found for the current sun angle.")
