import _anki_connect as ac
import _context as c
import _utils as u
import html
from os.path import exists

type2deck = {
  "concept": "1 concept",
  "structure": "2 structure",
  "context": "3 context",
}


def add_notes():
  notes = dict()

  for n in c.Note.Notes.values():
    if (n.type not in c.notesA): 
      continue

    notes[n.uid] = ({
      "deckName": type2deck[n.type],
      "modelName": "MD Basic",
      "fields": {
        "id": n.uid,
        "front": html.escape(n.front).replace("\n", "<br>").replace("/Tex/image/",""),
        "back": html.escape(n.back).replace("\n", "<br>").replace("/Tex/image/",""),
        "memo": html.escape(n.memo).replace("\n", "<br>"),
        "aliases": f"[{', '.join(n.aliases)}]",
        "tree": n.tree.replace("\n", "<br>"),
      },
      "tags": n.tags + ["NoteType::" + n.type]
    })
  return notes


def update_anki(notes, links):
  notes = list(notes.values())
  bool_table = ac.invoke("canAddNotes", notes=notes)

  for i in range(len(bool_table)):
    time.sleep(0.01)
    if (bool_table[i]):  
      ac.invoke("addNote", note=notes[i])
    else:  #updnate
      notes[i]["id"] = links[notes[i]["fields"]["id"]]
      ac.invoke("updateNote", note=notes[i])
  print("Added {}".format(sum(bool_table)))


def remove_notes(links):
  a_not_z, _ = u.sync()
  deletes = [links[uid] for uid in set(a_not_z)]
  ac.invoke("deleteNotes", notes=deletes)
  print("Deleted {}".format(len(deletes)))


def main():
  c.add_context()
  links = u.link_uid()
  notes = add_notes()
  remove_notes(links)
  update_anki(notes, links)
  print("Completed!")

main()
