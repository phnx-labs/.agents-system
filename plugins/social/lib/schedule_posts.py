"""Schedule the v2 batch to X + LinkedIn via getlate (rush http POST).
Test-fires #1, verifies, then schedules the rest. Prints every postId."""
import json, subprocess, sys, time
from pathlib import Path

HERE = Path(__file__).resolve().parent
plan = json.load(open(HERE / "batch_scheduled_plan.json"))["posts"]
PLAT = {"X": "twitter", "LinkedIn": "linkedin"}

def post(item):
    payload = {"platform": PLAT[item["platform"]], "text": item["text"], "scheduleDate": item["date"]}
    r = subprocess.run(["rush", "http", "POST", "/api/v1/social/post", "-d", json.dumps(payload)],
                       capture_output=True, text=True)
    out = (r.stdout or "") + (r.stderr or "")
    i = out.find("{")
    body = {}
    if i >= 0:
        try: body = json.loads(out[i:])
        except Exception: pass
    pid = body.get("postId") or body.get("id") or (body.get("post") or {}).get("id")
    ok = ("200" in out.split("\n")[0] or "201" in out.split("\n")[0] or bool(pid))
    return ok, pid, out[:200]

results = []
# test fire #1
ok, pid, raw = post(plan[0])
print(f"[TEST] {plan[0]['date'][:10]} {plan[0]['platform']} -> ok={ok} id={pid}")
if not ok:
    print("TEST FAILED — aborting. Response:\n", raw); sys.exit(1)
results.append((plan[0], pid))
# rest
for item in plan[1:]:
    ok, pid, raw = post(item)
    print(f"  {item['date'][:10]} {item['platform']:8} eng{item['engagement']} -> ok={ok} id={pid}")
    results.append((item, pid if ok else None))
    time.sleep(0.4)

good = [r for r in results if r[1]]
print(f"\nSCHEDULED {len(good)}/{len(plan)}")
json.dump([{"date": it["date"], "platform": it["platform"], "postId": pid,
            "first_line": it["text"].splitlines()[0]} for it, pid in results],
          open(HERE / "scheduled_ids.json", "w"), indent=2)
print("ids -> staging/scheduled_ids.json")
