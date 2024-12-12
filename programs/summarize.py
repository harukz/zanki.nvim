import _context as c
import collections

def summarize():
    refs = [note for note in c.Note.Notes.values() if note.type == "reference"]
    
    for ref in refs:
        ref.size = sum(len(chap.child) for chap in ref.child)
    
    max_width = max(len(ref.title) for ref in refs) + 5
    refs.sort(key=lambda x: x.size, reverse=True)

    with open("tmp.md", "w", encoding="utf-8") as f:
        f.write(f"┏━━{'━' * max_width}┳{'━' * 20}┳{'━' * 6}┓\n")
        f.write(f"┃ Title {' ' * (max_width - 5)}┃ Link {' ' * 14}┃ Size ┃\n")
        f.write(f"┣━━{'━' * max_width}╋{'━' * 20}╋{'━' * 6}┫\n")
        for ref in refs:
            f.write(f"┃ {ref.title:<{max_width}} ┃ [[{ref.uid}]] ┃ {ref.size:4} ┃\n")
        f.write(f"┗━━{'━' * max_width}┻{'━' * 20}┻{'━' * 6}┛\n")

def tag_info():
    tags = [note.type for note in c.Note.Notes.values()]
    tag_counts = collections.Counter(tags)
    a_total = sum(v for k, v in tag_counts.items() if k not in ["reference", "index"])

    with open("tmp.md", "a", encoding="utf-8") as f:
        f.write(f"\nTotal number of files: {len(c.Note.Notes.values())}\n")
        for k, v in tag_counts.items():
            f.write(f"-> {k:12}: {v}\n")
        f.write(f"A_total: {a_total}\n")

def chap_info(refs, max_width):
    with open("tmp.md", "a", encoding="utf-8") as f:
        f.write("\nReference details\n")
        for ref in refs:
            f.write(f"{ref.title}\n")
            for chap in ref.child:
                f.write(f"- {chap.title[:max_width-5]:<{max_width}} {len(chap.child)}\n")
            f.write("\n\n")

def orphan_info():
    orphan = [note for note in c.Note.Notes.values() if ((not note.parent) and (not note.child) and (note.type != "tmp"))]
    with open("tmp.md", "a", encoding="utf-8") as f:
        f.write(f"\nOrphan ({len(orphan)})\n")
        for note in orphan:
            f.write(f"  ┣━━ {note.title} [[{note.uid}]]\n")

def link_orphan():
    cnt = sum(1 for note in c.Note.Notes.values() if not note.require and note.type not in ["reference", "memo", "index"])
    with open("tmp.md", "a", encoding="utf-8") as f:
        f.write(f"\nLink orphan ({cnt})\n")

def main():
    c.add_context()
    summarize()
    tag_info()
    # chap_info(refs, max_width)  
    link_orphan()
    orphan_info()
    print("Completed")

main()
