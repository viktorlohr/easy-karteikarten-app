#!/usr/bin/env python3
from pathlib import Path

# Common LaTeX auxiliary file extensions to remove
LATEX_EXTENSIONS = {
    ".aux",
    ".log",
    ".synctex.gz",
    ".fdb_latexmk",
    ".fls",
    ".toc",
    ".out",
    ".bbl",
    ".blg",
    ".nav",
    ".snm",
    ".vrb",
    ".lof",
    ".lot",
}


def clean_latex_junk(target_dir: str = "."):
    root = Path(target_dir).resolve()
    print(f"Scanning for LaTeX junk in: {root}")

    removed_count = 0
    for path in root.rglob("*"):
        # Skip directories and check extension
        if path.is_file() and path.suffix.lower() in LATEX_EXTENSIONS:
            try:
                path.unlink()
                print(f"Deleted: {path.relative_to(root)}")
                removed_count += 1
            except Exception as e:
                print(f"Failed to delete {path.relative_to(root)}: {e}")

    print(f"\nDone! Cleaned up {removed_count} build file(s).")


if __name__ == "__main__":
    clean_latex_junk()
