# Kling 3.0 Video Generation (k3z)

**Skill:** `video-k3z` (k3z = Kling 3 Zero = Kling 3.0)

Read and follow `~/.claude/skills/video-k3z/SKILL.md` to generate a Kling 3.0 video.

## User's Request

$ARGUMENTS

## Instructions

1. Read the SKILL.md file to understand the workflow
2. If the user provided an image path, use it. Otherwise, ask for the image path.
3. Craft a motion prompt following the guidelines in the skill
4. Execute the generation workflow step by step
5. Monitor until the video is queued

Remember:
- Always upload to START FRAME ONLY (never both frames)
- Use `agent-browser snapshot -i` to find current element references
- Verify state before each action
- Use 1080p resolution and 5-6s duration unless user specifies otherwise
