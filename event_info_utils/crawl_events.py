import re
import os
import sys
from file_io import FileIO
from pathlib import Path
from typing import Dict, Any, Optional
from event_analyzer import EventAnalyzer

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python analyze_bb_events_v3.py <path_to_events_directory> [output_file_name]")
        sys.exit(1)
    
    events_dir = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else 'event_requirements'

    analyzer = EventAnalyzer()
    analyzer.iterate_through_squirrel_files(events_dir, output_file)