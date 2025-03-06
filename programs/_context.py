import re
import glob
import _variables as v

class Note():
  """
  This class assumes the notes are in the right format; code is position dependent. 
  """
  Notes = {}

  def __init__(self, path):
    self.uid = str(path[10:-3])
    self.title = None
    self.aliases = None
    self.type = None
    self.tags = []
    self.front = None
    self.back = None
    self.memo = None
    self.tree = None
    self.require = []
    self.required = []

    self.parent = []  # list of instance for ref, index
    self.child = []  # list of instance for ref, index
    self.links = []  # list of uid for ref, index note

    try:
      self.get_all(path)
    except:
      print("[[" + self.uid + "]]")

    Note.Notes[self.uid] = self  # uid = self

  def get_all(self, path):
    with open(path, "r", encoding="utf-8") as f:
      content = f.read()
    sections = [section.strip() for section in content.split("---")[1:]]  #ignore first ---
    frontmatter = sections[0].splitlines()

    self.aliases = [e.strip() for e in frontmatter[0][10:-1].split(",")]
    self.title = self.aliases[0]
    self.require = eval(frontmatter[1][9:].rstrip())
    self.tags = [e.strip() for e in frontmatter[2][7:-1].rstrip().split(",") if e.strip() in ["leech", "image:True", "suspended"]]
    self.type = frontmatter[3][6:].strip()
    self.memo = sections[-2][7:].strip()
    self.tree = sections[-1].strip()

    if (self.type in v.notesB):
      self.front = sections[1].strip()
      self.back = sections[2].strip()
    else:
      self.front = self.title
      back = [b for b in sections[1].splitlines()][1:]
      self.back = "\n".join(back).strip()

    self.links = [b[b.find("[[") + 2:b.find("[[") + 16] for b in self.back.splitlines() if "[[" in b]


def find_instance(uid):
  return Note.Notes[str(uid)]


def gen_database():
  files = glob.glob("./Slipbox/*")
  for file in files:
    Note(file)  # Generate data base


def add_context():
  gen_database()
  refs = [note for note in Note.Notes.values() if note.type == "reference"]

  for ref in refs:
    for chap_link in ref.links:
      chap = find_instance(chap_link)

      ref.child.append(chap)
      chap.parent.append(ref)
      chap.tags.append(ref.title)

      for at_link in chap.links:
        at = find_instance(at_link)

        chap.child.append(at)
        at.parent.append(chap)
        tmp = ref.title + "::" + chap.title
        at.tags.append(tmp.replace(" ", "_"))
        for e in at.require:
          try:
            if (str(e) != "0"): find_instance(e).required.append(at.uid)
          except KeyError: # remove if invalid key
            at.require.remove(e)
