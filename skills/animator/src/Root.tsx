import React from "react";
import { Composition } from "remotion";
import "../primitives/fonts";
import { AgentDispatch } from "../compositions/AgentDispatch";

// Render at native 4K. Downscale to 1080p/720p for upload — see RECIPES.md §7.
const FPS = 30;
const W_4K = 3840;
const H_4K = 2160;

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="AgentDispatch"
        component={AgentDispatch}
        durationInFrames={FPS * 8}
        fps={FPS}
        width={W_4K}
        height={H_4K}
      />
    </>
  );
};
