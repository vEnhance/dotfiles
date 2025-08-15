#!/usr/bin/env python3
"""
UltiSnips to VSCode snippets converter for blink.cmp

This script converts UltiSnips snippets to VSCode JSON format
for use with blink.cmp in Neovim.

(Generated entirely by Claude Code, to give due credit)
"""

import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List


@dataclass
class Snippet:
    """Represents a parsed snippet."""

    trigger: str
    description: str
    body: List[str]
    flags: str = ""


class UltiSnipsParser:
    """Parser for UltiSnips format."""

    def __init__(self):
        self.snippet_pattern = re.compile(
            r'^snippet\s+(\S+)(?:\s+"([^"]*)")?\s*([iAwb]*)\s*$'
        )

    def parse_file(self, file_path: Path) -> List[Snippet]:
        """Parse a single UltiSnips file and return list of snippets."""
        snippets = []

        try:
            with open(file_path, "r", encoding="utf-8") as f:
                lines = f.readlines()
        except UnicodeDecodeError:
            print(f"Warning: Could not decode {file_path}, skipping...")
            return snippets

        i = 0
        while i < len(lines):
            line = lines[i].rstrip()

            # Skip comments and empty lines
            if line.startswith("#") or not line.strip():
                i += 1
                continue

            # Check for snippet start
            match = self.snippet_pattern.match(line)
            if match:
                trigger = match.group(1)
                description = match.group(2) or trigger
                flags = match.group(3) or ""

                # Parse snippet body
                i += 1
                body_lines = []
                while i < len(lines):
                    line = lines[i].rstrip()
                    if line == "endsnippet":
                        break
                    body_lines.append(line)
                    i += 1

                snippets.append(
                    Snippet(
                        trigger=trigger,
                        description=description,
                        body=body_lines,
                        flags=flags,
                    )
                )

            i += 1

        return snippets


class VSCodeConverter:
    """Converts snippets to VSCode JSON format."""

    def __init__(self):
        self.placeholder_pattern = re.compile(r"\$\{(\d+):(<\+([^>]*)\+>|([^}]*))\}")

    def convert_placeholder(self, text: str) -> str:
        """Convert UltiSnips placeholder syntax to VSCode format."""

        def replace_placeholder(match):
            num = match.group(1)
            content = match.group(3) or match.group(4) or ""
            # Remove <+ +> markers from UltiSnips format
            content = content.strip()
            if content:
                return f"${{{num}:{content}}}"
            else:
                return f"${num}"

        # Handle $0 (final cursor position)
        text = re.sub(r"\$0", "$0", text)

        # Handle numbered placeholders
        text = self.placeholder_pattern.sub(replace_placeholder, text)

        return text

    def convert_snippet(self, snippet: Snippet) -> Dict:
        """Convert a single snippet to VSCode format."""
        # Convert body lines
        converted_body = []
        for line in snippet.body:
            converted_line = self.convert_placeholder(line)
            converted_body.append(converted_line)

        return {
            "prefix": snippet.trigger,
            "body": converted_body,
            "description": snippet.description,
        }

    def convert_snippets(self, snippets: List[Snippet]) -> Dict:
        """Convert a list of snippets to VSCode JSON format."""
        result = {}

        for snippet in snippets:
            # Use description as the snippet name, fallback to trigger
            name = (
                snippet.description
                if snippet.description != snippet.trigger
                else snippet.trigger
            )
            # Ensure unique names
            base_name = name
            counter = 1
            while name in result:
                name = f"{base_name}_{counter}"
                counter += 1

            result[name] = self.convert_snippet(snippet)

        return result


class SnippetConverter:
    """Main converter class."""

    def __init__(self, vim_snips_dir: Path, nvim_snippets_dir: Path):
        self.vim_snips_dir = vim_snips_dir
        self.nvim_snippets_dir = nvim_snippets_dir
        self.parser = UltiSnipsParser()
        self.converter = VSCodeConverter()

    def get_language_from_path(self, file_path: Path) -> str:
        """Determine language from file path."""
        # Handle nested directories (e.g., markdown/blog.snippets -> markdown)
        relative_path = file_path.relative_to(self.vim_snips_dir)

        if len(relative_path.parts) > 1:
            # File is in a subdirectory, use directory name as language
            return relative_path.parts[0]
        else:
            # File is in root, use filename without extension
            return file_path.stem

    def collect_snippet_files(self) -> Dict[str, List[Path]]:
        """Collect all snippet files grouped by language."""
        files_by_language = {}

        for file_path in self.vim_snips_dir.rglob("*.snippets"):
            language = self.get_language_from_path(file_path)

            if language not in files_by_language:
                files_by_language[language] = []
            files_by_language[language].append(file_path)

        return files_by_language

    def convert_language(self, language: str, file_paths: List[Path]) -> Dict:
        """Convert all snippets for a given language."""
        all_snippets = []

        for file_path in file_paths:
            print(f"Processing {file_path}...")
            snippets = self.parser.parse_file(file_path)
            all_snippets.extend(snippets)

        return self.converter.convert_snippets(all_snippets)

    def create_package_json(self, languages: List[str]) -> Dict:
        """Create package.json for VSCode snippets."""
        snippets_config = []

        for language in sorted(languages):
            snippets_config.append({"language": language, "path": f"./{language}.json"})

        return {
            "name": "converted-ultisnips",
            "displayName": "Converted UltiSnips",
            "description": "Snippets converted from UltiSnips format",
            "version": "1.0.0",
            "contributes": {"snippets": snippets_config},
        }

    def convert_all(self):
        """Convert all snippets and create output structure."""
        # Create output directory
        self.nvim_snippets_dir.mkdir(parents=True, exist_ok=True)

        # Collect all snippet files
        files_by_language = self.collect_snippet_files()

        print(
            f"Found {len(files_by_language)} languages: {list(files_by_language.keys())}"
        )

        # Convert each language
        for language, file_paths in files_by_language.items():
            print(f"\nConverting {language} snippets...")
            snippets_dict = self.convert_language(language, file_paths)

            # Write JSON file
            output_file = self.nvim_snippets_dir / f"{language}.json"
            with open(output_file, "w", encoding="utf-8") as f:
                json.dump(snippets_dict, f, indent=2, ensure_ascii=False)

            print(f"Created {output_file} with {len(snippets_dict)} snippets")

        # Create package.json
        package_json = self.create_package_json(list(files_by_language.keys()))
        package_file = self.nvim_snippets_dir / "package.json"
        with open(package_file, "w", encoding="utf-8") as f:
            json.dump(package_json, f, indent=2, ensure_ascii=False)

        print(f"\nCreated {package_file}")
        print(f"Conversion complete! Output in {self.nvim_snippets_dir}")


def main():
    """Main entry point."""
    # Set up paths
    dotfiles_dir = Path(__file__).parent
    vim_snips_dir = dotfiles_dir / "vim" / "snips"
    nvim_snippets_dir = dotfiles_dir / "nvim" / "snippets"

    if not vim_snips_dir.exists():
        print(f"Error: UltiSnips directory not found: {vim_snips_dir}")
        return 1

    # Create converter and run
    converter = SnippetConverter(vim_snips_dir, nvim_snippets_dir)
    converter.convert_all()

    return 0


if __name__ == "__main__":
    exit(main())
