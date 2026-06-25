import pandas as pd
import numpy as np
import json
import hashlib

d = pd.read_parquet('data/clean/drafts_mapped.parquet')
links = pd.read_parquet('data/clean/links.parquet')
d['dt'] = pd.to_datetime(d['date'])
d['month'] = d['dt'].dt.to_period('M').astype(str)

N = len(d)
out = {}

def pct(x, n=N):
    return round(100.0 * x / n, 2)

print("="*70)
print("1. DUPLICATION / NEAR-DUP WASTE")
print("="*70)
ndup = int(d['is_dup'].sum())
print(f"Total drafts: {N}")
print(f"is_dup=True: {ndup}  ({pct(ndup)}%)")
out['dup_rate_overall_pct'] = pct(ndup)
out['dup_count'] = ndup
out['total_drafts'] = N

print("\n-- is_dup rate per account --")
acc = d.groupby('account')['is_dup'].agg(['sum','count'])
acc['pct'] = (100*acc['sum']/acc['count']).round(2)
print(acc)
out['dup_rate_by_account'] = {k: round(v,2) for k,v in (100*acc['sum']/acc['count']).items()}

print("\n-- is_dup rate per month (trend) --")
mon = d.groupby('month')['is_dup'].agg(['sum','count'])
mon['pct'] = (100*mon['sum']/mon['count']).round(2)
print(mon)
out['dup_rate_by_month'] = {k: round(v,2) for k,v in (100*mon['sum']/mon['count']).items()}

# Exact-text dup groups (normalize whitespace/case)
norm = d['text'].fillna('').str.strip().str.lower().str.replace(r'\s+',' ', regex=True)
d['_norm'] = norm
grp = d.groupby('_norm').size().sort_values(ascending=False)
multi = grp[grp>1]
wasted = int((grp[grp>1] - 1).sum())  # extra copies beyond first
print(f"\n-- Exact-normalized text groups --")
print(f"Distinct normalized texts: {grp.shape[0]}")
print(f"Texts appearing >1x: {multi.shape[0]}")
print(f"Wasted redundant copies (sum of size-1): {wasted}  ({pct(wasted)}% of all drafts)")
out['exact_dup_groups'] = int(multi.shape[0])
out['exact_dup_wasted_copies'] = wasted
out['exact_dup_wasted_pct'] = pct(wasted)
print("\n-- Top 10 most-duplicated texts (group size, preview) --")
top_groups = []
for txt, sz in grp.head(10).items():
    prev = txt[:90].replace('\n',' ')
    print(f"  {sz:4d}x | {prev}")
    top_groups.append({'size': int(sz), 'preview': prev})
out['top_dup_groups'] = top_groups

print("\n" + "="*70)
print("2. OUTPUT CADENCE & VOLUME DISCIPLINE")
print("="*70)
per_day = d.groupby('date').size()
active_days = per_day.shape[0]
print(f"Active days (with >=1 draft): {active_days}")
print(f"Drafts/day: mean={per_day.mean():.1f} median={per_day.median():.0f} max={per_day.max()} min={per_day.min()}")
print("Drafts/day quantiles:")
print(per_day.quantile([.5,.75,.9,.95,.99]).round(1))
out['active_days'] = int(active_days)
out['drafts_per_day_mean'] = round(float(per_day.mean()),1)
out['drafts_per_day_median'] = float(per_day.median())
out['drafts_per_day_max'] = int(per_day.max())
out['drafts_per_day_p95'] = round(float(per_day.quantile(.95)),1)
print("\n-- Top 10 over-produced days --")
op = []
for dd, c in per_day.sort_values(ascending=False).head(10).items():
    # dup rate that day
    dr = d[d['date']==dd]['is_dup'].mean()*100
    print(f"  {dd}: {c} drafts  (is_dup {dr:.1f}%)")
    op.append({'date': dd, 'count': int(c), 'dup_pct': round(dr,1)})
out['top_overproduced_days'] = op

# Does high-volume day correlate with more duplication? (novelty vs volume)
day_df = d.groupby('date').agg(n=('id','size'), dup=('is_dup','mean'))
corr = day_df['n'].corr(day_df['dup'])
print(f"\nCorrelation (drafts/day vs dup-rate that day): r = {corr:.3f}")
out['corr_volume_vs_dup'] = round(float(corr),3)

print("\n-- type split (reply vs standalone) --")
ts = d['type'].value_counts()
print(ts)
out['type_split'] = {k:int(v) for k,v in ts.items()}
out['type_split_pct'] = {k:pct(v) for k,v in ts.items()}

print("\n" + "="*70)
print("3. THEME / COVERAGE HEALTH")
print("="*70)
has_theme = d['theme'].notna() & (d['theme'].astype(str).str.strip()!='') & (d['theme'].astype(str)!='None')
nht = int(has_theme.sum())
print(f"Drafts with a theme tag: {nht}  ({pct(nht)}%)")
print(f"Drafts WITHOUT theme: {N-nht}  ({pct(N-nht)}%)")
out['theme_tagged_pct'] = pct(nht)
out['no_theme_pct'] = pct(N-nht)

def gini(x):
    x = np.sort(np.asarray(x, dtype=float))
    n = len(x)
    if n==0 or x.sum()==0: return 0.0
    cum = np.cumsum(x)
    return float((n+1-2*np.sum(cum)/cum[-1])/n)

print("\n-- Theme concentration --")
tc = d[has_theme]['theme'].value_counts()
print(tc)
print(f"Gini (themes, tagged only): {gini(tc.values):.3f}")
out['theme_gini'] = round(gini(tc.values),3)
out['theme_counts'] = {k:int(v) for k,v in tc.items()}

print("\n-- Pillar concentration --")
pc = d['pillar'].value_counts(dropna=False)
print(pc.head(20))
print(f"Gini (pillars): {gini(pc.values):.3f}")
out['pillar_gini'] = round(gini(pc.values),3)
out['pillar_counts'] = {str(k):int(v) for k,v in pc.head(20).items()}

print("\n-- Cluster concentration --")
cc = d['cluster'].value_counts()
print(f"n clusters: {cc.shape[0]}, top cluster has {cc.iloc[0]} ({pct(cc.iloc[0])}%)")
print(f"Top 5 clusters cover: {pct(cc.head(5).sum())}%")
print(f"Gini (clusters): {gini(cc.values):.3f}")
out['n_clusters'] = int(cc.shape[0])
out['top_cluster_pct'] = pct(cc.iloc[0])
out['top5_cluster_pct'] = pct(cc.head(5).sum())
out['cluster_gini'] = round(gini(cc.values),3)

print("\n-- word_count per platform --")
wc = d.groupby('platform')['word_count'].agg(['mean','median','min','max','count'])
print(wc.round(1))
out['wordcount_by_platform'] = {k: {'mean':round(float(r['mean']),1),'median':float(r['median'])} for k,r in wc.iterrows()}

print("\n" + "="*70)
print("4. SENT vs UNSENT")
print("="*70)
nsent = int(d['sent'].sum())
print(f"Sent: {nsent}  ({pct(nsent)}%)  | Unsent: {N-nsent}  ({pct(N-nsent)}%)")
out['sent_pct'] = pct(nsent)
out['unsent_count'] = N-nsent
print("\n-- unsent by account --")
ua = d.groupby('account')['sent'].agg(lambda s:(~s).sum())
print(ua)
print("\n-- unsent by platform --")
up = d.groupby('platform')['sent'].agg(lambda s:(~s).sum())
print(up)
print("\n-- unsent by month --")
um = d.groupby('month')['sent'].agg(n=('size'), unsent=lambda s:(~s).sum())
print(um)
print("\n-- unsent: is_dup rate vs sent --")
print("  dup-rate among unsent:", round(d[~d['sent']]['is_dup'].mean()*100,2),"%")
print("  dup-rate among sent:  ", round(d[d['sent']]['is_dup'].mean()*100,2),"%")
print("  median word_count unsent:", d[~d['sent']]['word_count'].median(), "| sent:", d[d['sent']]['word_count'].median())
out['unsent_by_account'] = {k:int(v) for k,v in ua.items()}
out['unsent_dup_rate_pct'] = round(d[~d['sent']]['is_dup'].mean()*100,2)
out['sent_dup_rate_pct'] = round(d[d['sent']]['is_dup'].mean()*100,2)

print("\n" + "="*70)
print("5. SOURCING QUALITY")
print("="*70)
lk = links.groupby('draft_id').size()
linked_ids = set(lk.index)
d['n_links'] = d['id'].map(lk).fillna(0).astype(int)
zero = int((d['n_links']==0).sum())
print(f"Drafts with 0 links: {zero}  ({pct(zero)}%)")
print(f"Drafts with >=1 link: {N-zero}  ({pct(N-zero)}%)")
print("links-per-draft quantiles:")
print(d['n_links'].quantile([.5,.75,.9,.95,.99]).round(1))
print(f"max links on one draft: {d['n_links'].max()}")
out['zero_link_pct'] = pct(zero)
out['links_per_draft_median'] = float(d['n_links'].median())
out['links_per_draft_max'] = int(d['n_links'].max())

print("\n-- Domain diversity --")
nd = links['domain'].nunique()
print(f"Unique domains: {nd}  across {len(links)} link rows")
dom = links['domain'].value_counts()
print("\nTop 10 domains (share of all link rows):")
for dm, c in dom.head(10).items():
    print(f"  {dm:28s} {c:5d}  ({100*c/len(links):.1f}%)")
print(f"\nTop domain share: {100*dom.iloc[0]/len(links):.1f}%")
print(f"Top 3 domains cover: {100*dom.head(3).sum()/len(links):.1f}% of all links")
print(f"Domain Gini: {gini(dom.values):.3f}")
yc = dom.get('ycombinator.com',0); gr = dom.get('getrush.ai',0)
print(f"\nSelf/aggregator citation: ycombinator.com={yc} ({100*yc/len(links):.1f}%), getrush.ai={gr} ({100*gr/len(links):.1f}%)")
print(f"Combined yc+getrush: {100*(yc+gr)/len(links):.1f}% of all citations")
out['unique_domains'] = int(nd)
out['top_domain'] = dom.index[0]
out['top_domain_share_pct'] = round(100*dom.iloc[0]/len(links),1)
out['top3_domain_share_pct'] = round(100*dom.head(3).sum()/len(links),1)
out['domain_gini'] = round(gini(dom.values),3)
out['yc_share_pct'] = round(100*yc/len(links),1)
out['getrush_share_pct'] = round(100*gr/len(links),1)
out['yc_plus_getrush_share_pct'] = round(100*(yc+gr)/len(links),1)

# how many drafts cite getrush (self-citation reach)
self_drafts = links[links['domain']=='getrush.ai']['draft_id'].nunique()
print(f"Drafts citing getrush.ai: {self_drafts} ({pct(self_drafts)}% of drafts)")
out['drafts_citing_getrush_pct'] = pct(self_drafts)

with open('report/perf_audit.json','w') as f:
    json.dump(out, f, indent=2)
print("\n\nWROTE report/perf_audit.json")
