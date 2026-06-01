import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame, useVideoConfig, Easing, spring } from "remotion";
import { COLORS } from "../primitives/colors";
import { FONTS } from "../primitives/fonts";

type Agent = { name: string };

const DEFAULT_AGENTS: Agent[] = [
  { name: "search" },
  { name: "summarize" },
  { name: "translate" },
  { name: "format" },
];

/**
 * AgentDispatch — 8s.
 * Central node emits agents in a staggered fan, each with a gold trail.
 */
export const AgentDispatch: React.FC<{ agents?: Agent[] }> = ({ agents = DEFAULT_AGENTS }) => {
  const frame = useCurrentFrame();
  const { fps, width, height } = useVideoConfig();
  const cx = width / 2;
  const cy = height / 2;
  const radius = Math.min(width, height) * 0.32;
  const scale = width / 1920;

  const titleOpacity = interpolate(frame, [0, fps * 0.6], [0, 1], { extrapolateRight: "clamp" });

  return (
    <AbsoluteFill style={{ background: COLORS.ink, fontFamily: FONTS.mono }}>
      {/* Outer aura — soft */}
      <div
        style={{
          position: "absolute",
          left: cx - 120 * scale,
          top: cy - 120 * scale,
          width: 240 * scale,
          height: 240 * scale,
          borderRadius: "50%",
          background: `radial-gradient(circle at 50% 50%, ${COLORS.gold} 0%, ${COLORS.goldLo} 60%, transparent 100%)`,
          opacity: 0.55,
          filter: `blur(${20 * scale}px)`,
        }}
      />
      {/* Center node */}
      <div
        style={{
          position: "absolute",
          left: cx - 40 * scale,
          top: cy - 40 * scale,
          width: 80 * scale,
          height: 80 * scale,
          borderRadius: "50%",
          background: COLORS.goldHi,
          boxShadow: `0 0 ${80 * scale}px ${COLORS.gold}`,
        }}
      />

      {agents.map((agent, i) => {
        const startFrame = fps * 0.4 + i * fps * 0.35;
        const angle = -Math.PI / 2 + (i - (agents.length - 1) / 2) * 0.7;
        const targetX = cx + Math.cos(angle) * radius;
        const targetY = cy + Math.sin(angle) * radius;

        const progress = spring({
          frame: frame - startFrame,
          fps,
          config: { damping: 14, mass: 0.6, stiffness: 80 },
        });

        const x = interpolate(progress, [0, 1], [cx, targetX]);
        const y = interpolate(progress, [0, 1], [cy, targetY]);
        const opacity = interpolate(progress, [0, 0.2, 1], [0, 1, 1]);

        return (
          <div key={agent.name}>
            <svg
              style={{
                position: "absolute",
                inset: 0,
                width: "100%",
                height: "100%",
                pointerEvents: "none",
                opacity: opacity * 0.5,
              }}
            >
              <line
                x1={cx}
                y1={cy}
                x2={x}
                y2={y}
                stroke={COLORS.gold}
                strokeWidth={2.4 * scale}
                strokeDasharray={`${8 * scale} ${12 * scale}`}
                strokeLinecap="round"
              />
            </svg>

            <div
              style={{
                position: "absolute",
                left: x - 180 * scale,
                top: y - 36 * scale,
                width: 360 * scale,
                padding: `${14 * scale}px ${32 * scale}px`,
                borderRadius: 48 * scale,
                background: COLORS.ink,
                border: `${2 * scale}px solid ${COLORS.gold}`,
                color: COLORS.paper,
                fontSize: 36 * scale,
                fontWeight: 500,
                textAlign: "center",
                opacity,
                boxShadow: `0 ${8 * scale}px ${40 * scale}px rgba(201,169,98,0.22)`,
              }}
            >
              {agent.name}
            </div>
          </div>
        );
      })}

      <div
        style={{
          position: "absolute",
          bottom: height * 0.08,
          left: 0,
          right: 0,
          textAlign: "center",
          fontSize: 56 * scale,
          color: COLORS.silver,
          letterSpacing: "0.02em",
          fontFamily: FONTS.serif,
          opacity: titleOpacity,
        }}
      >
        agents, dispatched.
      </div>
    </AbsoluteFill>
  );
};
