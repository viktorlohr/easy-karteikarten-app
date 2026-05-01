import subprocess
from pathlib import Path

def pdflatex(tex_file):
  print(f"Compiling {tex_file}.")
  subprocess.run(["pdflatex", "-interaction=nonstopmode",tex_file],
                 stdout=subprocess.DEVNULL,  # Hides standard output
                  stderr=subprocess.DEVNULL   # Hides error messages
                  )

def pdf_to_webp(pdf_file):
  pdf_file = Path(pdf_file)
  webp_file = pdf_file.with_suffix(".webp")
  subprocess.run(f"magick -density 300 {pdf_file.name} -quality 90 {webp_file.name}", 
                 shell=True,
                  )
  if not webp_file.exists():
    print(f"🚫 Could not create {webp_file}") 
  else:
    print(f"✅ Successfully created {webp_file}")

def tex_to_webp(tex_file):
  pdflatex(tex_file)
  tex_file = Path(tex_file)
  pdf_file = tex_file.with_suffix(".pdf")
  pdf_to_webp(pdf_file.name)
  return


def all_tex_to_webp():
  
      tex_to_webp(tex_file)

if __name__ == "__main__":
  answer = input("Alle? (y/n) ")
  if answer == "y":
    _answer = input("vorher kompilieren? (y/n)")

    for tex_file in Path('.').glob("*.tex"):
      if tex_file.name not in ["preamble.tex", "vorlage.tex"]:
        if _answer == "y":
          pdflatex(tex_file)
        pdf_to_webp(tex_file.with_suffix(".pdf"))
    

  else:
    pdf_file = input("Dateiname eingeben: ")
    tex_to_webp(pdf_file)