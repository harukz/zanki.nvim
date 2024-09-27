import _anki_connect as ac
import _utils as u
import _context as c
import sys


def sync():
  # List files only existing in one media
  a_not_z, z_not_a = u.sync()
  content = "In a but not in z\n" + "".join(f"[[{uid}]]\n" for uid in a_not_z)
  content += "In z but not in a\n" + "".join(f"[[{uid}]]\n" for uid in z_not_a)
  u.w2tmp(content)


def sync_anki():
  # Sync Anki with Anki web
  ac.invoke(action="sync")


def get_suspended():
  # List suspended notes in Anki to tmp file
  suspended = ac.invoke('notesInfo', notes=ac.invoke("findNotes", query="is:suspended"))
  content = f"Suspended: {len(suspended)} notes\n" + "\n".join(
      [f"[[{n['fields']['id']['value']}|{n['fields']['front']['value']}]]" for n in suspended])
  u.w2tmp(content)


def a2z_sus():
  # Sync Anki suspended notes with Zettel tags.
  only_z, only_a = u.sus_diff()
  c.add_context()

  for uid, action in [(only_a, 'append'), (only_z, 'remove')]:
    for u in uid:
      getattr(c.find_instance(u).tags, action)("suspended")

  u.formatter(c.Note.Notes.values())


def z2a_sus():
  # Based on the zettel data, update Anki suspended notes.
  only_z, only_a = u.sus_diff()
  links = u.link_uid()

  ac.invoke("suspend", cards=[links[uid] for uid in only_z])
  ac.invoke("unsuspend", cards=[links[uid] for uid in only_a])


def write_orphan():
  # List orphan note in tmp
  c.add_context()
  refs = [note for note in c.Note.Notes.values() if note.type == "reference"]
  par = []
  for ref in refs:
    for ch in ref.child:
      content = (ch.title + "\n[[" + ch.uid + "|" + ch.title + "]]\n")
      size = 0
      for at in ch.child:
        if ((len(at.require) == 0) and (at.type != "memo")):
          content += ("- [[" + at.uid + "|" + at.title + "]]\n")
          size += 1
      par.append([size, content])

  par.sort()

  with open("./tmp.md", mode="w") as f:
    for e in par:
      if (e[0] != 0):
        f.write(f"size: {e[0]} : ")
        f.write(e[1])

def show_parent():
  # List parents
  c.add_context()
  a = c.find_instance(sys.argv[2])
  u.w2tmp(u.gen_tree(a, max_depth=-1,use_required=False)[0])

def show_child():
  # List children 
  c.add_context()
  a = c.find_instance(sys.argv[2])
  u.w2tmp(u.gen_tree(a, max_depth=-1)[0])


if __name__ == "__main__":
  function_name = sys.argv[1]
  function_map = {
      "sync": sync,
      "sync_anki": sync_anki,
      "get_suspended": get_suspended,
      "a2z_sus": a2z_sus,
      "z2a_sus": z2a_sus,
      "write_orphan": write_orphan,
      "show_child": show_child,
      "show_parent": show_parent,
  }

  if function_name in function_map:
    function_map[function_name]()  
  else:
    print(f"{function_name} does not exist.")
