#!/usr/bin/env python3
"""TRIBE v2 Brain Engagement Analyzer.

Predicts neural activation across brain regions for text, audio, or video content.
Uses Meta's TRIBE v2 model trained on 720 real fMRI brain scans.

Usage:
    python3 analyze.py --text "Your text here"
    python3 analyze.py --input paragraphs.json
    python3 analyze.py --audio recording.mp3
    python3 analyze.py --batch posts.json
"""

import os
import sys
import json
import argparse

os.environ.setdefault("CUDA_VISIBLE_DEVICES", "")

import torch
torch.cuda.is_available = lambda: False  # Force CPU mode

from tribev2.demo_utils import TribeModel
from pathlib import Path
import numpy as np
from gtts import gTTS
from nilearn import datasets


CACHE = Path("./cache")
CACHE.mkdir(exist_ok=True)

# Brain region definitions (Destrieux atlas on fsaverage5)
REGION_GROUPS = {
    "Language": [
        "G_front_inf-Opercular", "G_front_inf-Triangul",
        "G_temp_sup-Lateral", "G_temp_sup-Plan_tempo", "S_temporal_sup",
    ],
    "Attention": [
        "G_front_sup", "G_front_middle",
        "G_parietal_sup", "G_pariet_inf-Supramar", "G_and_S_cingul-Mid-Ant",
    ],
    "Emotion": [
        "G_and_S_cingul-Ant", "G_cingul-Post-dorsal", "G_cingul-Post-ventral",
        "Pole_temporal", "G_oc-temp_med-Parahip",
    ],
    "Memory": [
        "G_temp_sup-Lateral", "G_temporal_middle", "G_temporal_inf",
        "G_oc-temp_med-Parahip",
    ],
    "DefaultMode": [
        "G_precuneus", "G_cingul-Post-dorsal",
        "G_front_sup", "G_pariet_inf-Angular",
    ],
}


def build_region_masks():
    """Build boolean masks mapping brain vertices to region groups."""
    destrieux = datasets.fetch_atlas_surf_destrieux()
    all_labels = np.concatenate([
        np.array(destrieux.map_left),
        np.array(destrieux.map_right),
    ])
    label_names = destrieux.labels

    masks = {}
    for group_name, regions in REGION_GROUPS.items():
        mask = np.zeros(len(all_labels), dtype=bool)
        for region in regions:
            for i, name in enumerate(label_names):
                if region in name:
                    mask |= (all_labels == i)
        masks[group_name] = mask
    return masks


def text_to_audio(text: str, output_path: Path) -> Path:
    """Convert text to speech audio file."""
    tts = gTTS(text=text, lang="en")
    tts.save(str(output_path))
    return output_path


def analyze(model, region_masks, title: str, paragraphs: list[str]):
    """Run TRIBE v2 analysis on a list of paragraphs."""
    print(f"\n{'=' * 110}")
    print(f"TRIBE v2 BRAIN ANALYSIS: '{title}'")
    print(f"{'=' * 110}")

    full_text = " ".join(paragraphs)
    slug = "".join(c if c.isalnum() or c == "_" else "_" for c in title.lower())
    audio_path = CACHE / f"brain_scan_{slug}.mp3"

    print("  Text -> Speech...", end=" ", flush=True)
    text_to_audio(full_text, audio_path)
    print("done.")

    print("  Extracting audio features...", end=" ", flush=True)
    df = model.get_events_dataframe(audio_path=audio_path)
    print("done.")

    print("  Predicting brain responses...", end=" ", flush=True)
    preds, segments = model.predict(events=df)
    print(f"done. ({preds.shape[0]}t x {preds.shape[1]}v)")

    # Map timesteps to paragraphs
    total_chars = sum(len(p) for p in paragraphs)
    cumulative = 0

    print(f"\n{'Para':>4} | {'Ovrl':>6} | {'Lang':>6} | {'Attn':>6} | {'Emot':>6} | {'Mem':>6} | {'Mind':>6} | Text")
    print("-" * 110)

    para_scores = []
    for j, para in enumerate(paragraphs):
        start_frac = cumulative / total_chars
        end_frac = (cumulative + len(para)) / total_chars
        start_t = int(start_frac * len(preds))
        end_t = max(start_t + 1, min(int(end_frac * len(preds)), len(preds)))
        pp = preds[start_t:end_t]

        scores = {"overall": float(np.mean(np.abs(pp)))}
        for gn, mask in region_masks.items():
            scores[gn] = float(np.mean(np.abs(pp[:, mask]))) if mask.sum() > 0 else 0.0

        para_scores.append(scores)
        print(
            f" P{j+1:2d} | {scores['overall']:.4f}"
            f" | {scores['Language']:.4f}"
            f" | {scores['Attention']:.4f}"
            f" | {scores['Emotion']:.4f}"
            f" | {scores['Memory']:.4f}"
            f" | {scores['DefaultMode']:.4f}"
            f" | {para[:55]}"
        )
        cumulative += len(para)

    # Rankings
    ranked = sorted(enumerate(para_scores), key=lambda x: -x[1]["overall"])
    top_n = min(5, len(ranked))
    bot_n = min(5, len(ranked))

    print(f"\nTOP {top_n} (highest brain engagement):")
    for r, (i, s) in enumerate(ranked[:top_n]):
        print(f"  #{r+1}: P{i+1} ({s['overall']:.4f}) {paragraphs[i][:80]}")

    print(f"\nBOTTOM {bot_n} (dead zones):")
    for r, (i, s) in enumerate(ranked[-bot_n:]):
        print(f"  #{len(ranked)-bot_n+1+r}: P{i+1} ({s['overall']:.4f}) {paragraphs[i][:80]}")

    # Engagement curve
    avg_act = [float(np.mean(np.abs(p))) for p in preds]
    n = len(avg_act)
    if n >= 4:
        qs = [np.mean(avg_act[i * n // 4:(i + 1) * n // 4]) for i in range(4)]
        labels = ["Opening", "Build-up", "Middle", "Closing"]
        print(f"\nENGAGEMENT CURVE:")
        for i, q in enumerate(qs):
            print(f"  {labels[i]:8s}: {q:.4f} {'#' * int(q * 200)}")
        drop = ((qs[0] - qs[3]) / qs[0] * 100) if qs[0] > 0 else 0
        print(f"  Drop Q1->Q4: {drop:.0f}%")
        if drop > 40:
            print(f"  WARNING: >{drop:.0f}% drop. Post loses readers. Move high-engagement content later.")

    return para_scores


def main():
    parser = argparse.ArgumentParser(description="TRIBE v2 Brain Engagement Analyzer")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--text", help="Inline text to analyze")
    group.add_argument("--input", help="JSON file with list of paragraphs")
    group.add_argument("--audio", help="Audio file path to analyze directly")
    group.add_argument("--batch", help="JSON file with {title: [paragraphs]} mapping")
    args = parser.parse_args()

    print("Loading TRIBE v2 model (CPU mode)...")
    model = TribeModel.from_pretrained("facebook/tribev2", cache_folder=CACHE)
    model.data.features_to_use = ["audio"]
    print("Model loaded (audio-only mode).\n")

    region_masks = build_region_masks()

    if args.text:
        paragraphs = [p.strip() for p in args.text.split("\n\n") if p.strip()]
        analyze(model, region_masks, "Input Text", paragraphs)

    elif args.input:
        with open(args.input) as f:
            data = json.load(f)
        if isinstance(data, list):
            analyze(model, region_masks, Path(args.input).stem, data)
        elif isinstance(data, dict) and "paragraphs" in data:
            analyze(model, region_masks, data.get("title", "Input"), data["paragraphs"])

    elif args.audio:
        print(f"Audio input: {args.audio}")
        df = model.get_events_dataframe(audio_path=args.audio)
        preds, segments = model.predict(events=df)
        avg_act = [float(np.mean(np.abs(p))) for p in preds]
        print(f"\n{'=' * 80}")
        print(f"BRAIN ENGAGEMENT OVER TIME ({len(preds)} timesteps)")
        print(f"{'=' * 80}")
        for i, act in enumerate(avg_act):
            bar = "#" * int(act * 200)
            print(f"t={i:3d} | {act:.4f} | {bar}")
        print(f"\nPeak: t={np.argmax(avg_act)} ({max(avg_act):.4f})")
        print(f"Low:  t={np.argmin(avg_act)} ({min(avg_act):.4f})")
        print(f"Mean: {np.mean(avg_act):.4f}")

    elif args.batch:
        with open(args.batch) as f:
            posts = json.load(f)
        for title, paragraphs in posts.items():
            analyze(model, region_masks, title, paragraphs)

    print("\nDONE.")


if __name__ == "__main__":
    main()
