#!/usr/bin/env python3
"""
Setup script for Voice-Controlled Video Cutter
This can be used to create a distributable package
"""

from setuptools import setup, find_packages
import os

# Read README file
def read_readme():
    readme_path = os.path.join(os.path.dirname(__file__), 'README.md')
    if os.path.exists(readme_path):
        with open(readme_path, 'r', encoding='utf-8') as f:
            return f.read()
    return ""

# Read requirements
def read_requirements():
    req_path = os.path.join(os.path.dirname(__file__), 'requirements.txt')
    if os.path.exists(req_path):
        with open(req_path, 'r', encoding='utf-8') as f:
            return [line.strip() for line in f if line.strip() and not line.startswith('#')]
    return []

setup(
    name="voice-video-cutter",
    version="1.2.0",
    author="Voice Video Cutter Team",
    description="A desktop application for cutting videos using voice commands",
    long_description=read_readme(),
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/voice-video-cutter",
    
    # Package information
    packages=find_packages(),
    py_modules=["main"],
    
    # Dependencies
    install_requires=read_requirements(),
    
    # Python version requirement
    python_requires=">=3.7",
    
    # Entry points
    entry_points={
        'console_scripts': [
            'voice-video-cutter=main:main',
        ],
    },
    
    # Package data
    include_package_data=True,
    package_data={
        '': ['*.txt', '*.md', '*.bat', '*.ps1'],
    },
    
    # Classification
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: End Users/Desktop",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Topic :: Multimedia :: Video",
        "Topic :: Multimedia :: Video :: Non-Linear Editor",
        "Environment :: X11 Applications :: Qt",
        "Environment :: Win32 (MS Windows)",
        "Environment :: MacOS X",
    ],
    
    # Keywords
    keywords="video, cutting, voice, recognition, ffmpeg, gui, tkinter",
    
    # Project URLs
    project_urls={
        "Bug Reports": "https://github.com/yourusername/voice-video-cutter/issues",
        "Source": "https://github.com/yourusername/voice-video-cutter",
        "Documentation": "https://github.com/yourusername/voice-video-cutter/blob/main/README.md",
    },
    
    # Additional metadata
    zip_safe=False,
)