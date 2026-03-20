import json
import sys
import re
from pathlib import Path
from typing import Dict, List, Any, Optional

class FileIO:
    def __init__(self) -> None:
        pass

    @staticmethod
    def get_squirrel_files_in_directory(directory: str):
        event_dir = Path(directory)

        if not event_dir.exists():
            print(f"Error: Directory '{directory}' does not exist", file=sys.stderr)
            return []
        
        squirrel_files = list(event_dir.rglob('*.nut'))

        if not squirrel_files:
            return []

        return squirrel_files


    @staticmethod
    def generate_json_file(events: List[Dict[str, Any]], output_file: str):
        json_string = json.dumps(events)

        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(json_string)

    @staticmethod
    def generate_squirrel_file(events: List[Dict[str, Any]], output_file: str):
        lines = [
            "// Battle Brothers Event Requirements Database",
            f"// Total events: {len(events)}",
            "",
            "this.EventRequirements <- [",
        ]
        
        for i, event in enumerate(events):
            lines.append("    {")
            
            for key, value in sorted(event.items()):
                squirrel_value = FileIO.convert_python_to_squirrel(value)
                lines.append(f"        {key} = {squirrel_value},")
            
            if i < len(events) - 1:
                lines.append("    },")
            else:
                lines.append("    }")
            
            #lines.append("")
        
        lines.append("];")
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write('\n'.join(lines))

    @staticmethod
    def convert_python_to_squirrel(value):
        if value is None:
            return "null"
        elif isinstance(value, bool):
            return "true" if value else "false"
        elif isinstance(value, int):
            return str(value)
        elif isinstance(value, float):
            return str(value)
        elif isinstance(value, str):
            escaped = value.replace('\\', '\\\\').replace('"', '\\"')
            return f'"{escaped}"'
        elif isinstance(value, dict):
            if not value:
                return "{}"
            items = []
            for k, v in value.items():
                squirrel_val = FileIO.convert_python_to_squirrel(v)
                items.append(f"{k} = {squirrel_val}")
            return "{ " + ", ".join(items) + " }"
        elif isinstance(value, list):
            if not value:
                return "[]"
            items = [FileIO.convert_python_to_squirrel(item) for item in value]
            return "[" + ", ".join(items) + "]"
        return "null"
    
    @staticmethod
    def extract_function_from_file(content: str, func_name: str) -> Optional[str]:
        pattern = rf'function\s+{func_name}\s*\([^)]*\)\s*{{'
        match = re.search(pattern, content)
        if not match:
            return None
        
        start = match.end() - 1
        brace_count = 0
        i = start
        while i < len(content):
            if content[i] == '{':
                brace_count += 1
            elif content[i] == '}':
                brace_count -= 1
                if brace_count == 0:
                    return content[start:i+1]
            i += 1
        
        return None
    
    @staticmethod
    def get_if_block_contents(file_content: str, if_line: str) -> str:
        if not file_content:
            print("onUpdateScore() function not found")
            return ""
        
        lines = file_content.split('\n')
        
        # Find the index of the if statement line
        if_index = None
        for i, line in enumerate(lines):
            if if_line in line.strip():
                if_index = i
                break
        
        if if_index is None:
            print("if_index is None")
            return ""

        # Find the opening brace
        brace_index = None
        for i in range(if_index, len(lines)):
            if '{' in lines[i]:
                brace_index = i
                break

        if brace_index is None:
            print("brace_index is None")
            return ""

        # Collect lines until closing brace
        contents = []
        for i in range(brace_index + 1, len(lines)):
            if '}' in lines[i]:
                break
            contents.append(lines[i].strip())

        return '\n'.join(contents)
    
    @staticmethod
    def get_else_block_contents(file_content: str, if_line: str) -> str:
        if not file_content:
            print("onUpdateScore() function not found")
            return ""
        
        lines = file_content.split('\n')
        
        # Find the index of the if statement line
        if_index = None
        for i, line in enumerate(lines):
            if if_line in line.strip():
                if_index = i
                break
        
        if if_index is None:
            print("if_index is None")
            return ""
        
        # Find the closing brace of the if block
        brace_count = 0
        started = False
        if_closing_index = None
        
        for i in range(if_index, len(lines)):
            line = lines[i]
            
            # Count braces
            for char in line:
                if char == '{':
                    brace_count += 1
                    started = True
                elif char == '}':
                    brace_count -= 1
                    
                    # Found the closing brace of the if block
                    if started and brace_count == 0:
                        if_closing_index = i
                        break
            
            if if_closing_index is not None:
                break
        
        if if_closing_index is None:
            print("if_closing_index is None - couldn't find end of if block")
            return ""
        
        # Look for 'else' after the if block closing brace
        # Check the same line first, then subsequent lines
        else_index = None
        
        # Check if else is on the same line as the closing brace
        closing_line = lines[if_closing_index].strip()
        if 'else' in closing_line:
            # } else { or } else if (
            else_index = if_closing_index
        else:
            # Check next few lines for else
            for i in range(if_closing_index + 1, min(if_closing_index + 5, len(lines))):
                line = lines[i].strip()
                
                # Skip empty lines and comments
                if not line or line.startswith('//'):
                    continue
                
                # Found else
                if line.startswith('else'):
                    else_index = i
                    break
                
                # Found something else (not an else clause)
                if line and not line.startswith('//'):
                    break
        
        if else_index is None:
            return ""  # No else clause found
        
        # Now extract the else block contents
        else_line = lines[else_index]
        
        # Check if it's else-if
        if 'if' in else_line and '(' in else_line:
            # else if (...) - treat it like a regular if statement
            # Find its opening brace
            else_brace_index = None
            for i in range(else_index, len(lines)):
                if '{' in lines[i]:
                    else_brace_index = i
                    break
            
            if else_brace_index is None:
                return else_line.strip()  # Single line else-if
            
            # Collect contents
            contents = []
            brace_count = 0
            started = False
            
            for i in range(else_brace_index, len(lines)):
                line = lines[i]
                
                for char in line:
                    if char == '{':
                        brace_count += 1
                        started = True
                    elif char == '}':
                        brace_count -= 1
                        if started and brace_count == 0:
                            return '\n'.join(contents)
                
                # Add line content (skip the opening brace line)
                if i > else_brace_index:
                    contents.append(lines[i].strip())
            
            return '\n'.join(contents)
        
        # Regular else block
        else:
            # Find opening brace for else
            else_brace_index = None
            for i in range(else_index, len(lines)):
                if '{' in lines[i]:
                    else_brace_index = i
                    break
            
            if else_brace_index is None:
                # Single line else without braces: else return;
                return else_line.replace('else', '').strip()
            
            # Collect else block contents
            contents = []
            for i in range(else_brace_index + 1, len(lines)):
                if '}' in lines[i]:
                    break
                contents.append(lines[i].strip())
            
            return '\n'.join(contents)