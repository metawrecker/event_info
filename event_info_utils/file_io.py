import json
from typing import Dict, List, Any

class FileIO:
    def __init__(self) -> None:
        pass

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