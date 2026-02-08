#!/usr/bin/env python3
"""
Comprehensive Visual Testing Script for Aquarium App
Uses ADB to navigate through every screen and capture screenshots
"""

import subprocess
import time
import os
from datetime import datetime

ADB = "/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe"
PACKAGE = "com.tiarnanlarkin.aquarium.aquarium_app"
SCREENSHOT_DIR = "/tmp/aquarium_screenshots"

class VisualTester:
    def __init__(self):
        self.screenshots = []
        self.issues = []
        os.makedirs(SCREENSHOT_DIR, exist_ok=True)
        
    def adb(self, *args):
        """Run ADB command"""
        cmd = [ADB] + list(args)
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.stdout.strip()
    
    def tap(self, x, y):
        """Tap at coordinates"""
        self.adb("shell", "input", "tap", str(x), str(y))
        time.sleep(1)
    
    def swipe(self, x1, y1, x2, y2, duration=300):
        """Swipe gesture"""
        self.adb("shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), str(duration))
        time.sleep(1)
    
    def screenshot(self, name):
        """Take screenshot"""
        filepath = f"{SCREENSHOT_DIR}/{len(self.screenshots)+1:02d}_{name}.png"
        # Use proper subprocess pipe to save screenshot
        cmd = [ADB, "exec-out", "screencap", "-p"]
        result = subprocess.run(cmd, capture_output=True)
        with open(filepath, 'wb') as f:
            f.write(result.stdout)
        self.screenshots.append((name, filepath))
        print(f"📸 Screenshot: {name}")
        return filepath
    
    def check_text(self, text):
        """Check if text exists on screen"""
        output = self.adb("shell", "dumpsys", "window", "windows")
        return text in output
    
    def launch_app(self):
        """Launch the app"""
        print("\n🚀 Launching app...")
        self.adb("shell", "monkey", "-p", PACKAGE, "-c", "android.intent.category.LAUNCHER", "1")
        time.sleep(3)
    
    def test_onboarding(self):
        """Test onboarding flow"""
        print("\n📱 Testing Onboarding Flow...")
        
        # Screen 1
        self.screenshot("onboarding_01_track_tanks")
        time.sleep(1)
        
        # Tap Next
        self.tap(465, 1428)
        self.screenshot("onboarding_02_screen2")
        
        # Tap Next again
        self.tap(465, 1428)
        self.screenshot("onboarding_03_screen3")
        
        # Skip to profile
        self.tap(622, 109)
        time.sleep(2)
        self.screenshot("onboarding_04_profile_creation")
    
    def test_profile_creation(self):
        """Test profile creation form"""
        print("\n👤 Testing Profile Creation...")
        
        # Take screenshot of top
        self.screenshot("profile_01_top")
        
        # Select "Some experience"
        self.tap(350, 877)  # Some experience card
        time.sleep(1)
        self.screenshot("profile_02_experience_selected")
        
        # Scroll down to tank type
        self.swipe(540, 1200, 540, 600)
        time.sleep(1)
        self.screenshot("profile_03_scrolled_to_tank_type")
        
        # Check for overflow warnings visually
        # If yellow text "OVERFLOW" is visible, it's the known bug
        
        # Tap Freshwater
        self.tap(191, 1335)
        time.sleep(1)
        self.screenshot("profile_04_freshwater_selected")
        
        # Scroll down to goals
        self.swipe(540, 1200, 540, 400)
        time.sleep(1)
        self.screenshot("profile_05_goals_section")
        
        # Tap a goal
        self.tap(193, 1097)  # "Happy, healthy fish"
        time.sleep(1)
        self.screenshot("profile_06_goal_selected")
        
        # Try to continue (may need valid selections)
        self.swipe(540, 1800, 540, 1200)  # Scroll to button
        time.sleep(1)
        self.screenshot("profile_07_continue_button")
    
    def test_main_screens(self):
        """Navigate through main app screens"""
        print("\n🏠 Testing Main App Screens...")
        
        # If we're past onboarding, capture main screens
        time.sleep(2)
        self.screenshot("main_01_home_or_placement")
        
        # Try to navigate (these coordinates would need to be adjusted based on actual UI)
        # For now, just capture current state
        
        # Back button
        self.adb("shell", "input", "keyevent", "KEYCODE_BACK")
        time.sleep(1)
        self.screenshot("main_02_after_back")
        
        # Another back
        self.adb("shell", "input", "keyevent", "KEYCODE_BACK")
        time.sleep(1)
        self.screenshot("main_03_after_back2")
    
    def test_ui_elements(self):
        """Check for specific UI elements"""
        print("\n🔍 Checking UI Elements...")
        
        # Dump UI hierarchy
        self.adb("shell", "uiautomator", "dump")
        hierarchy = self.adb("shell", "cat", "/sdcard/window_dump.xml")
        
        # Check for key elements
        elements_to_check = [
            "Welcome to Aquarium",
            "Experience Level",
            "Primary Tank Type",
            "Your Goals",
        ]
        
        found = []
        missing = []
        for element in elements_to_check:
            if element in hierarchy:
                found.append(element)
            else:
                missing.append(element)
        
        print(f"✅ Found elements: {found}")
        if missing:
            print(f"⚠️  Missing elements: {missing}")
            self.issues.append(f"Missing UI elements: {missing}")
    
    def generate_report(self):
        """Generate test report"""
        print("\n" + "="*60)
        print("📊 VISUAL TEST REPORT")
        print("="*60)
        print(f"\n📸 Screenshots captured: {len(self.screenshots)}")
        for i, (name, path) in enumerate(self.screenshots, 1):
            print(f"  {i}. {name}")
        
        print(f"\n📁 Screenshots saved to: {SCREENSHOT_DIR}")
        
        if self.issues:
            print(f"\n⚠️  Issues found: {len(self.issues)}")
            for issue in self.issues:
                print(f"  - {issue}")
        else:
            print("\n✅ No issues detected!")
        
        print("\n" + "="*60)
        
        # Create HTML report
        html_report = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Aquarium App Visual Test Report</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; }}
        h1 {{ color: #2c3e50; }}
        .screenshot {{ margin: 20px 0; padding: 10px; border: 1px solid #ddd; }}
        img {{ max-width: 300px; border: 1px solid #ccc; }}
        .issue {{ background: #fff3cd; padding: 10px; margin: 10px 0; border-left: 4px solid #ffc107; }}
    </style>
</head>
<body>
    <h1>Aquarium App Visual Test Report</h1>
    <p>Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
    <p>Total Screenshots: {len(self.screenshots)}</p>
    
    <h2>Screenshots</h2>
    {''.join(f'<div class="screenshot"><h3>{name}</h3><img src="{path}"></div>' for name, path in self.screenshots)}
    
    <h2>Issues</h2>
    {''.join(f'<div class="issue">{issue}</div>' for issue in self.issues) if self.issues else '<p>✅ No issues detected!</p>'}
</body>
</html>
"""
        
        report_path = f"{SCREENSHOT_DIR}/test_report.html"
        with open(report_path, 'w') as f:
            f.write(html_report)
        
        print(f"\n📄 HTML Report: {report_path}")
    
    def run_full_test(self):
        """Run complete visual test suite"""
        print("\n" + "="*60)
        print("🧪 AQUARIUM APP COMPREHENSIVE VISUAL TEST")
        print("="*60)
        
        try:
            # Launch app
            self.launch_app()
            
            # Test each section
            self.test_onboarding()
            self.test_profile_creation()
            self.test_ui_elements()
            self.test_main_screens()
            
        except Exception as e:
            print(f"\n❌ Error during testing: {e}")
            self.issues.append(f"Test error: {str(e)}")
        
        finally:
            # Generate report
            self.generate_report()

if __name__ == "__main__":
    tester = VisualTester()
    tester.run_full_test()
