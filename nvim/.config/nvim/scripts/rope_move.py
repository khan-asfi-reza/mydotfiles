#!/usr/bin/env python3
"""Move a Python symbol to another file, updating imports project-wide.

Usage: rope_move.py <project_root> <source_file> <symbol_name> <dest_file>
"""
import re
import sys
from pathlib import Path

from rope.base.project import Project
from rope.refactor.move import create_move


def find_symbol_offset(source: str, name: str) -> int | None:
    pattern = re.compile(
        rf"^(?:async\s+)?(?:def|class)\s+{re.escape(name)}\b", re.MULTILINE
    )
    match = pattern.search(source)
    if match:
        return source.find(name, match.start())
    return None


def main() -> int:
    if len(sys.argv) != 5:
        print(
            "Usage: rope_move.py <project_root> <source_file> <symbol_name> <dest_file>",
            file=sys.stderr,
        )
        return 2

    project_root, source_file, symbol_name, dest_file = sys.argv[1:5]
    root = Path(project_root).resolve()

    project = Project(str(root))
    try:
        src_rel = str(Path(source_file).resolve().relative_to(root))
        dst_rel = str(Path(dest_file).resolve().relative_to(root))

        src_resource = project.get_resource(src_rel)
        offset = find_symbol_offset(src_resource.read(), symbol_name)
        if offset is None:
            print(
                f"Symbol '{symbol_name}' not found in {source_file}", file=sys.stderr
            )
            return 1

        dst_full = Path(dest_file)
        if not dst_full.exists():
            dst_full.parent.mkdir(parents=True, exist_ok=True)
            dst_full.touch()

        dst_resource = project.get_resource(dst_rel)
        mover = create_move(project, src_resource, offset)
        changes = mover.get_changes(dst_resource)
        project.do(changes)

        print(f"Moved '{symbol_name}' to {dest_file}")
        for resource in changes.get_changed_resources():
            print(f"  modified: {resource.path}")
        return 0
    finally:
        project.close()


if __name__ == "__main__":
    sys.exit(main())
