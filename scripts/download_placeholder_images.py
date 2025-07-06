#!/usr/bin/env python3
"""
Placeholder Image Downloader for WhatsApp MicroLearning Bot

This script downloads placeholder images from various free sources
to populate the assets folder for testing purposes.

Usage: python scripts/download_placeholder_images.py
"""

import os
import requests
import time
from pathlib import Path

# Base directory for assets
ASSETS_DIR = Path("assets/images")

# Placeholder image sources
PLACEHOLDER_SOURCES = {
    # Splash animations (using static placeholders for now)
    "splash": {
        "logo_animated.gif": "https://via.placeholder.com/200x200/4CAF50/FFFFFF?text=LOGO",
        "loading_animation.gif": "https://via.placeholder.com/100x100/2196F3/FFFFFF?text=LOAD",
        "brain_animation.gif": "https://via.placeholder.com/200x200/9C27B0/FFFFFF?text=BRAIN",
        "welcome_animation.gif": "https://via.placeholder.com/200x200/FF9800/FFFFFF?text=WELCOME",
    },
    
    # Onboarding illustrations
    "onboarding": {
        "onboarding_1.png": "https://via.placeholder.com/400x400/E3F2FD/1976D2?text=Welcome+to+Learning",
        "onboarding_2.png": "https://via.placeholder.com/400x400/F3E5F5/7B1FA2?text=AI+Powered",
        "onboarding_3.png": "https://via.placeholder.com/400x400/E8F5E8/388E3C?text=Learn+Anywhere",
        "onboarding_4.png": "https://via.placeholder.com/400x400/FFF3E0/F57C00?text=Track+Progress",
    },
    
    # Category icons
    "categories": {
        "programming.png": "https://via.placeholder.com/128x128/1976D2/FFFFFF?text=CODE",
        "design.png": "https://via.placeholder.com/128x128/E91E63/FFFFFF?text=DESIGN",
        "business.png": "https://via.placeholder.com/128x128/FF9800/FFFFFF?text=BIZ",
        "science.png": "https://via.placeholder.com/128x128/4CAF50/FFFFFF?text=SCI",
        "language.png": "https://via.placeholder.com/128x128/9C27B0/FFFFFF?text=LANG",
        "mathematics.png": "https://via.placeholder.com/128x128/F44336/FFFFFF?text=MATH",
        "history.png": "https://via.placeholder.com/128x128/795548/FFFFFF?text=HIST",
        "art.png": "https://via.placeholder.com/128x128/FF5722/FFFFFF?text=ART",
    },
    
    # Achievement badges
    "achievements": {
        "first_lesson.png": "https://via.placeholder.com/256x256/FFD700/FFFFFF?text=1st+LESSON",
        "streak_7.png": "https://via.placeholder.com/256x256/FF6B35/FFFFFF?text=7+DAYS",
        "streak_30.png": "https://via.placeholder.com/256x256/FF1744/FFFFFF?text=30+DAYS",
        "level_up.png": "https://via.placeholder.com/256x256/00E676/FFFFFF?text=LEVEL+UP",
        "topic_master.png": "https://via.placeholder.com/256x256/3F51B5/FFFFFF?text=MASTER",
        "social_learner.png": "https://via.placeholder.com/256x256/E91E63/FFFFFF?text=SOCIAL",
    },
    
    # Social assets
    "social": {
        "default_avatar.png": "https://via.placeholder.com/128x128/607D8B/FFFFFF?text=USER",
        "achievement_badge.png": "https://via.placeholder.com/64x64/FFD700/FFFFFF?text=BADGE",
        "streak_fire.png": "https://via.placeholder.com/64x64/FF5722/FFFFFF?text=FIRE",
        "milestone_flag.png": "https://via.placeholder.com/64x64/4CAF50/FFFFFF?text=FLAG",
    },
    
    # Illustrations
    "illustrations": {
        "empty_state_study_plans.png": "https://via.placeholder.com/300x300/E3F2FD/1976D2?text=No+Study+Plans",
        "empty_state_social.png": "https://via.placeholder.com/300x300/F3E5F5/7B1FA2?text=No+Social+Posts",
        "empty_state_categories.png": "https://via.placeholder.com/300x300/E8F5E8/388E3C?text=No+Categories",
        "offline_mode.png": "https://via.placeholder.com/300x300/FFF3E0/F57C00?text=Offline+Mode",
        "export_data.png": "https://via.placeholder.com/300x300/E0F2F1/00695C?text=Export+Data",
        "backup_success.png": "https://via.placeholder.com/300x300/E8F5E8/2E7D32?text=Backup+Success",
    },
    
    # Icons
    "icons": {
        "app_icon.png": "https://via.placeholder.com/512x512/4CAF50/FFFFFF?text=APP",
        "notification_icon.png": "https://via.placeholder.com/128x128/2196F3/FFFFFF?text=NOTIF",
        "widget_icon.png": "https://via.placeholder.com/256x256/FF9800/FFFFFF?text=WIDGET",
    },
    
    # Animations (using static placeholders)
    "animations": {
        "loading_dots.gif": "https://via.placeholder.com/100x100/2196F3/FFFFFF?text=DOTS",
        "success_checkmark.gif": "https://via.placeholder.com/100x100/4CAF50/FFFFFF?text=SUCCESS",
        "error_animation.gif": "https://via.placeholder.com/100x100/F44336/FFFFFF?text=ERROR",
        "progress_animation.gif": "https://via.placeholder.com/100x100/FF9800/FFFFFF?text=PROGRESS",
    },
}

def download_image(url, filepath):
    """Download an image from URL to filepath"""
    try:
        print(f"Downloading {filepath.name}...")
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        
        # Create directory if it doesn't exist
        filepath.parent.mkdir(parents=True, exist_ok=True)
        
        # Write image data
        with open(filepath, 'wb') as f:
            f.write(response.content)
        
        print(f"✅ Downloaded {filepath.name}")
        return True
        
    except Exception as e:
        print(f"❌ Failed to download {filepath.name}: {e}")
        return False

def main():
    """Main function to download all placeholder images"""
    print("🎨 WhatsApp MicroLearning Bot - Placeholder Image Downloader")
    print("=" * 60)
    
    total_images = sum(len(images) for images in PLACEHOLDER_SOURCES.values())
    downloaded = 0
    failed = 0
    
    for category, images in PLACEHOLDER_SOURCES.items():
        print(f"\n📁 Downloading {category} images...")
        category_dir = ASSETS_DIR / category
        
        for filename, url in images.items():
            filepath = category_dir / filename
            
            # Skip if file already exists
            if filepath.exists():
                print(f"⏭️  Skipping {filename} (already exists)")
                downloaded += 1
                continue
            
            # Download with retry
            success = download_image(url, filepath)
            if success:
                downloaded += 1
            else:
                failed += 1
            
            # Small delay to be respectful to the server
            time.sleep(0.5)
    
    print("\n" + "=" * 60)
    print(f"📊 Download Summary:")
    print(f"   Total images: {total_images}")
    print(f"   ✅ Downloaded: {downloaded}")
    print(f"   ❌ Failed: {failed}")
    
    if failed == 0:
        print("\n🎉 All placeholder images downloaded successfully!")
        print("\n📝 Next steps:")
        print("   1. Replace placeholder images with actual designs")
        print("   2. Add animated GIFs for splash and loading screens")
        print("   3. Optimize image sizes for mobile performance")
        print("   4. Test the app to see the visual improvements")
    else:
        print(f"\n⚠️  {failed} images failed to download. Please check your internet connection and try again.")

if __name__ == "__main__":
    main()
