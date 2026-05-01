from pathlib import Path
import subprocess

failure = False
for file in Path('.').glob('*.pdf'):
  webp_file = file.with_suffix(".webp")
  subprocess.run(f"magick -density 300 {file} -quality 90 {webp_file}", 
                 shell=True)
  if not webp_file.exists():
    print(f"Could not create {webp_file}")
    failure = True

if not failure:
  print("Every file got converted.")  