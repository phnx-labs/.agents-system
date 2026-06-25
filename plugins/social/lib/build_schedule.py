"""Re-dedup the v2 batch and build a collision-free Tue/Wed/Thu morning schedule.
Read-only (no posting). Writes staging/batch_scheduled_plan.json."""
import json, subprocess, datetime as dt
from pathlib import Path
import numpy as np
from sentence_transformers import SentenceTransformer

HERE = Path(__file__).resolve().parent
emb = np.load(HERE / "emma-v1/coverage_index/embeddings.npy")
posts = json.load(open(HERE / "batch_v2.json"))["posts"]
model = SentenceTransformer("BAAI/bge-small-en-v1.5")
q = model.encode([p["text"] for p in posts], normalize_embeddings=True).astype("float32")
sims = q @ emb.T
for i, p in enumerate(posts):
    p["dedup"] = round(float(sims[i].max()), 3)
print("re-dedup max:", max(p["dedup"] for p in posts), "| all NEW:", all(p["dedup"] < 0.90 for p in posts))

def fetch(path):
    out = subprocess.run(["rush", "http", "GET", path], capture_output=True, text=True).stdout
    i = out.find("{")
    return json.loads(out[i:]) if i >= 0 else {}

existing = set()
for pg in range(1, 4):
    d = fetch(f"/api/v1/social/scheduled?page={pg}")
    ps = d.get("posts", [])
    if not ps:
        break
    for p in ps:
        existing.add(p.get("scheduledFor", "")[:10])
print("existing scheduled dates:", sorted(existing))

posts.sort(key=lambda p: -p["engagement"])
days, d = [], dt.date(2026, 6, 25)
while len(days) < len(posts):
    if d.weekday() in (1, 2, 3):  # Tue/Wed/Thu
        days.append(d)
    d += dt.timedelta(days=1)

xs = [p for p in posts if p["platform"] == "X"]
lis = [p for p in posts if p["platform"] == "LinkedIn"]
order = []
while xs or lis:
    if xs:
        order.append(xs.pop(0))
    if lis:
        order.append(lis.pop(0))

plan = []
for p, day in zip(order, days):
    hour = 17 if str(day) in existing else 16  # offset if a date already has a post
    plan.append({**p, "date": f"{day}T{hour:02d}:00:00Z"})

json.dump({"posts": plan}, open(HERE / "batch_scheduled_plan.json", "w"), indent=2)
print("=== SCHEDULE PLAN (Tue/Wed/Thu mornings, alternating, best-first) ===")
for p in plan:
    print(f"  {p['date'][:10]} {p['platform']:8} eng{p['engagement']} | {p['text'].splitlines()[0][:60]}")
