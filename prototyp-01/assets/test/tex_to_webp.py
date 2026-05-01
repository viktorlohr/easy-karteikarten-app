import subprocess


def tex_to_webp(tex_file):
  subprocess.run(["pdflatex", tex_file])
  basename = tex_file[:-4]
  pdf_file = basename+".pdf"
  webp_file = basename+".webp"
  subprocess.run(f"magick -density 300 {pdf_file} -quality 90 {webp_file}", 
                 shell=True)
  return



if __name__ == "__main__":
  file = input("Dateiname eingeben: ")
  tex_to_webp(file)