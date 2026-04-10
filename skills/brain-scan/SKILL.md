---
name: brain-scan
description: Analyze content engagement using Meta TRIBE v2 brain simulation model. Predicts neural activation across language, attention, emotion, memory, and default-mode brain regions. Triggers on 'brain scan', 'engagement analysis', 'TRIBE v2', 'neural engagement', 'brain response', or content optimization requests.
argument-hint: "[file path, URL, or inline text]"
allowed-tools: Bash(ssh*), Bash(scp*), Bash(cat*), Bash(*/brain-scan/*)
user-invocable: true
---

# Brain Scan -- Neural Engagement Analyzer

Analyze any content (text, blog post, audio, video) using Meta's TRIBE v2 model to predict how a human brain responds to it over time. Trained on 720 real fMRI brain scans.

## What It Does

1. Takes content input (text file, markdown, URL, audio file, or raw text)
2. Converts to audio via gTTS if text (TRIBE v2 requires audio/video input)
3. Runs the TRIBE v2 brain prediction model on a remote GPU server
4. Maps predictions to 5 brain region groups (Language, Attention, Emotion, Memory, Default Mode)
5. Outputs per-paragraph engagement scores and actionable editing recommendations

## Environment

!`${CLAUDE_SKILL_DIR}/env.sh block`

## How to Run

### Step 1: Prepare content

Extract plain text paragraphs from the content. Strip all HTML, markdown formatting, frontmatter, image tags, and link syntax. Keep only the text a reader would actually read, split into logical paragraphs.

### Step 2: Upload and run

```bash
# Upload the analysis script
scp ${CLAUDE_SKILL_DIR}/analyze.py <SSH_TARGET>:~/brain_analyze.py

# Run with text input (paragraphs as JSON array)
ssh <SSH_TARGET> "source <VENV>/bin/activate && python3 ~/brain_analyze.py --input /path/to/text.json"

# Or run with audio input directly
ssh <SSH_TARGET> "source <VENV>/bin/activate && python3 ~/brain_analyze.py --audio /path/to/audio.mp3"

# Batch mode (multiple posts)
ssh <SSH_TARGET> "source <VENV>/bin/activate && python3 ~/brain_analyze.py --batch /path/to/posts.json"
```

Replace `<SSH_TARGET>` and `<VENV>` with values from the Environment section above.

### Step 3: Read results

Results are printed to stdout in a structured format:
- **Per-paragraph table**: Overall, Language, Attention, Emotion, Memory, DefaultMode scores
- **TOP 5 / BOTTOM 5**: Ranked paragraphs by engagement
- **Engagement curve**: Q1-Q4 showing how engagement changes through the piece
- **Drop %**: How much engagement falls from opening to closing

## Interpreting Results

| Region | High Means | Low Means | Writing Implication |
|--------|-----------|-----------|-------------------|
| **Language** (Broca/Wernicke) | Active parsing, novel concepts | Predictable, cliche phrasing | Use unexpected word choices, vary sentence structure |
| **Attention** (frontal/parietal) | Focused, directing mental resources | Zoning out, skimming | Lead with surprising facts, concrete numbers |
| **Emotion** (limbic) | Content felt, not just processed | Dry, abstract, impersonal | Add personal stakes, vivid imagery, conflict |
| **Memory** (temporal) | Encoding to memory, connecting to knowledge | Disconnected facts, jargon | Use stories, analogies, concrete examples |
| **Default Mode** | Mind WANDERING (bad) | Actively engaged (good) | Break predictable rhythm, add novelty |

## Practical Editing Rules

- **Hook check**: P1 should be in Top 3. If not, rewrite opening.
- **Dead zone fix**: Any paragraph in Bottom 3 with Attention < 0.08 needs rewriting or cutting.
- **Drop threshold**: Q1->Q4 drop > 40% means the post loses readers. Move high-engagement content later.
- **Emotion floor**: Paragraphs with Emotion < 0.06 are "dry" -- add human stakes or vivid imagery.
- **Default Mode ceiling**: If DefaultMode is highest region for any paragraph, that paragraph causes mind-wandering.

## Batch Input Format

```json
{
  "Post Title": ["paragraph 1", "paragraph 2", "..."],
  "Another Post": ["paragraph 1", "..."]
}
```

## Known Issues

- **Blackwell GPU incompatible**: PyTorch lacks CUDA kernels for sm_121. Falls back to CPU.
- **CPU speed**: ~2-3 min per post. Audio extraction is fast, Wav2Vec embeddings are moderate.
- **Audio-only mode**: Text extractor (Llama 3.2 3B) is too slow on CPU (~57s/word). We use audio-only features which skip Llama entirely. Brain predictions are based on how the text sounds when read aloud via gTTS.
- **gTTS quality**: Google TTS produces monotone speech. A better TTS (with prosody) would give more nuanced engagement predictions.
- **Paragraph-to-timestep mapping**: Uses character-count proportional mapping (paragraph length / total length * timesteps). Approximate but consistent.

## Setup (first time only)

Requires a machine with Python 3.10+ and ~10GB disk for model weights. GPU optional (CUDA-compatible preferred, falls back to CPU).

```bash
# Create venv and install
ssh <SSH_TARGET> "python3 -m venv ~/tribev2-env && source ~/tribev2-env/bin/activate && \
  pip install 'tribev2[plotting] @ git+https://github.com/facebookresearch/tribev2.git' uv && \
  pip install torch torchvision --force-reinstall --index-url https://download.pytorch.org/whl/cpu"

# Patch for CPU-only execution (skip if you have a compatible CUDA GPU)
ssh <SSH_TARGET> "source ~/tribev2-env/bin/activate && \
  sed -i 's/self.device = \"cuda\" if torch.cuda.is_available() else \"cpu\"/self.device = \"cpu\"/' \
    ~/tribev2-env/lib/python3.12/site-packages/neuralset/extractors/base.py \
    ~/tribev2-env/lib/python3.12/site-packages/neuralset/extractors/video.py && \
  sed -i 's/\.to(self\.device)/.to(\"cpu\")/g' \
    ~/tribev2-env/lib/python3.12/site-packages/neuralset/extractors/audio.py && \
  sed -i 's/compute_type = \"float16\"/compute_type = \"int8\"/' \
    ~/tribev2-env/lib/python3.12/site-packages/tribev2/eventstransforms.py && \
  sed -i 's/return get_audio_and_text_events(pd.DataFrame(\[event\]))/return get_audio_and_text_events(pd.DataFrame([event]), audio_only=True)/' \
    ~/tribev2-env/lib/python3.12/site-packages/tribev2/demo_utils.py"

# Set HF token (required for first model download)
# Add HF_TOKEN=hf_xxx to ~/.agents/.environment
```
