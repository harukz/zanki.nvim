import _anki_connect as ac
import _context as c
import _variables as v


def w2tmp(content):
  with open("./tmp.md", "w", encoding="utf-8") as f:
    f.write(content)


def link_uid():
  db = ac.invoke('notesInfo', notes=ac.invoke("findNotes", query="*"))
  return {note["fields"]["id"]["value"]: note["noteId"] for note in db}

def formatter(all):
  for n in all:
    with open(f"./Slipbox/{n.uid}.md", "w", encoding="utf-8") as f:
      f.write(f"---\naliases: [{', '.join(n.aliases)}]\n")
      f.write(f"parents: {n.require}\ntags: [{', '.join(sorted(list(set(n.tags))))}]\ntype: {n.type}\n---\n\n")

      if (n.type not in c.notesB): # not pro or ques
        f.write(f"# {n.title}\n")
      else:
        f.write(f"{n.front}\n\n---\n")

      f.write(f"{n.back}\n\n---\n")
      f.write(f"[Memo]\n{n.memo}\n\n---\n")

      f.write("**Parent**\n" + gen_tree(n,max_depth=2, use_required=False)[0] + "\n**Child**\n" + gen_tree(n,max_depth=2)[0])


def sync():
  c.add_context()
  all_z = [n.uid for n in c.Note.Notes.values() if n.type in v.notesA]
  all_a = [note["fields"]["id"]["value"] for note in ac.invoke('notesInfo', notes=ac.invoke("findNotes", query="*"))]

  z_not_a = [uid for uid in all_z if uid not in all_a]
  a_not_z = [uid for uid in all_a if uid not in all_z]

  return a_not_z, z_not_a


def sus_diff():
  c.add_context()
  zt_sus = [n.uid for n in c.Note.Notes.values() if "suspended" in n.tags]
  ak_sus = [n["fields"]["id"]["value"] for n in ac.invoke('notesInfo', notes=ac.invoke("findNotes", query="is:suspended"))]

  only_z = [n for n in zt_sus if n not in ak_sus]
  only_a = [n for n in ak_sus if n not in zt_sus]

  return only_z, only_a


def gen_tree(ins, max_depth=-1, n=0, use_required=True):
  tree = ["", 0]
  indent = ""
  tree_rec(ins, tree, indent, max_depth, n, use_required)
  return tree


def tree_rec(ins, tree, indent, max_depth, n, use_required):
  obj_key = 'required' if use_required else 'require'
  obj = sorted(set(getattr(ins, obj_key)) - {0})
  tree[0] += f"{ins.title}\n"
  tree[1] += 1

  if (max_depth != -1 and n > max_depth) or not obj:
    return

  for ch in obj[:-1]:
    tree[0] += f"{indent}┣━ "
    tree_rec(c.find_instance(ch), tree, f"{indent}┃   ", max_depth, n + 1, use_required)

  tree[0] += f"{indent}┗━ "
  tree_rec(c.find_instance(obj[-1]), tree, f"{indent}    ", max_depth, n + 1, use_required)
