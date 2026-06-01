import { delayRender, continueRender } from "remotion";
import { loadFont as loadEBGaramond } from "@remotion/google-fonts/EBGaramond";
import { loadFont as loadCormorantGaramond } from "@remotion/google-fonts/CormorantGaramond";
import { loadFont as loadCormorantUpright } from "@remotion/google-fonts/CormorantUpright";
import { loadFont as loadJetBrainsMono } from "@remotion/google-fonts/JetBrainsMono";
import { loadFont as loadInter } from "@remotion/google-fonts/Inter";

const handle = delayRender("loading fonts");

const eb = loadEBGaramond("normal", { weights: ["400", "500", "600"] });
const cormorant = loadCormorantGaramond("normal", { weights: ["300", "400"] });
const cormorantItalic = loadCormorantGaramond("italic", { weights: ["300"] });
const cormorantUpright = loadCormorantUpright("normal", { weights: ["500"] });
const jb = loadJetBrainsMono("normal", { weights: ["400", "500"] });
const inter = loadInter("normal", { weights: ["400", "500"] });

Promise.all([
  eb.waitUntilDone(),
  cormorant.waitUntilDone(),
  cormorantItalic.waitUntilDone(),
  cormorantUpright.waitUntilDone(),
  jb.waitUntilDone(),
  inter.waitUntilDone(),
])
  .then(() => continueRender(handle))
  .catch((err) => {
    console.error("font load failed", err);
    continueRender(handle);
  });

export const FONTS = {
  serif: eb.fontFamily,
  display: cormorant.fontFamily,
  displayItalic: cormorantItalic.fontFamily,
  upright: cormorantUpright.fontFamily,
  mono: jb.fontFamily,
  ui: inter.fontFamily,
} as const;
