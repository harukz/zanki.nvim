import _utils as u
import _context as c
from os.path import exists
import glob

files = glob.glob("./Slipbox/*")

def section_checker():
  fix = []

  for file in files:
    with open(file, "r", encoding="utf-8") as f:
      content = f.read()

    sections = [s.strip() for s in content.split("---")[1:]]  #ignore first ---
    frontmatter = sections[0].splitlines()

    uid = file[10:-3]
    tag = frontmatter[3][5:].rstrip()

    if ((tag in c.notesA or tag in c.notesC) and (len(sections) != 4)):
      fix.append(uid)
    if ((tag in c.notesB) and (len(sections) != 5)):
      fix.append(uid)

  return fix

def rem_line():
  for file in files:
    all = ""

    with open(file, "r", encoding="utf-8") as f:
      for line in f.readlines():
        if("[[" in line):
          link=line[line.find("[[")+2:line.find("[[")+16]
          if ((link.isdigit()) and (not exists("./Slipbox/" + link + ".md"))):
            continue
        all+=line

    with open(file, "w", encoding="utf-8") as f:
      f.write(all)


def main():
  rem_line()
  fix = section_checker()

  if not fix:
    c.add_context()
    u.formatter(c.Note.Notes.values())
  else:
    print("Following notes do not follow the format")
    for uid in fix:
      print(f"[[{uid}]]")

if __name__ == "__main__":
  main()
