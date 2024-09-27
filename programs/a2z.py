import _anki_connect as ac
import _context as c
import _utils as u
import html
import os

def update_context():
  db = ac.invoke('notesInfo', notes=ac.invoke("findNotes", query="*"))

  print(len(db))

  for note in db:
    try:
      ins = c.find_instance(note["fields"]["id"]["value"])

      ins.aliases = [e.strip() for e in note["fields"]["aliases"]["value"][1:-1].split(",")]
      ins.front = html.unescape(note["fields"]["front"]["value"].replace("<br>", "\n"))
      ins.back = html.unescape(note["fields"]["back"]["value"].replace("<br>", "\n"))
      ins.memo = html.unescape(note["fields"]["memo"]["value"].replace("<br>", "\n"))

      for s in note["tags"]:
        if s.startswith("NoteType::"):
          ins.type = s[10:]
        else:
          ins.tags.append(s.strip())
    except:
      pass

def rem():
  _, z_not_a = u.sync()

  for uid in set(z_not_a): 
    os.rename("./Slipbox/" + str(uid) + ".md", "./.recycle/" + str(uid) + ".md")

def main():
  c.add_context()
  update_context()
  all = c.Note.Notes.values()
  u.formatter(all)
  # rem()


main()
