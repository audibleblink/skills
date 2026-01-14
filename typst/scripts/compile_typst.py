#!/usr/bin/env python3
"""
Typst compilation script with comprehensive error handling and visual debugging support.

Usage:
    python compile_typst.py <input.typ> [output.pdf]
    
Features:
- Compiles Typst source to PDF
- Provides detailed error messages
- Returns compilation status for automation
"""

import subprocess
import sys
from pathlib import Path


def compile_typst(input_file: str, output_file: str = None) -> tuple[bool, str]:
    """
    Compile a Typst file to PDF.
    
    Args:
        input_file: Path to .typ source file
        output_file: Optional output PDF path (defaults to input name with .pdf extension)
    
    Returns:
        Tuple of (success: bool, message: str)
    """
    input_path = Path(input_file)
    
    # Validate input file exists
    if not input_path.exists():
        return False, f"Error: Input file '{input_file}' not found"
    
    if not input_path.suffix == '.typ':
        return False, f"Error: Input file must have .typ extension, got '{input_path.suffix}'"
    
    # Determine output path
    if output_file is None:
        output_path = input_path.with_suffix('.pdf')
    else:
        output_path = Path(output_file)
    
    # Run typst compile
    try:
        result = subprocess.run(
            ['typst', 'compile', str(input_path), str(output_path)],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            return True, f"Successfully compiled to {output_path}"
        else:
            error_msg = result.stderr if result.stderr else result.stdout
            return False, f"Compilation failed:\n{error_msg}"
            
    except FileNotFoundError:
        return False, "Error: 'typst' command not found. Ensure Typst CLI is installed and in PATH."
    except subprocess.TimeoutExpired:
        return False, "Error: Compilation timed out after 30 seconds"
    except Exception as e:
        return False, f"Unexpected error during compilation: {str(e)}"


def main():
    if len(sys.argv) < 2:
        print("Usage: python compile_typst.py <input.typ> [output.pdf]")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    success, message = compile_typst(input_file, output_file)
    print(message)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
