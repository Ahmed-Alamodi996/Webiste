"use client";

import { useEffect, useRef, useState } from "react";

interface TextScrambleProps {
  children: string;
  className?: string;
  delay?: number;
  speed?: number;
  style?: React.CSSProperties;
}

const GLYPHS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!<>-_\\/[]{}=+*^?#@";

export default function TextScramble({
  children,
  className = "",
  delay = 0,
  speed = 35,
  style,
}: TextScrambleProps) {
  const [display, setDisplay] = useState("");
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const hasRun = useRef(false);

  useEffect(() => {
    if (hasRun.current) return;
    hasRun.current = true;

    const text = children;
    const len = text.length;
    let frame = 0;

    const timeout = setTimeout(() => {
      timerRef.current = setInterval(() => {
        let output = "";
        for (let i = 0; i < len; i++) {
          if (text[i] === " ") {
            output += " ";
            continue;
          }
          // Characters resolve progressively from left to right
          const resolveFrame = Math.floor(i * 1.3) + 10;
          if (frame >= resolveFrame) {
            output += text[i];
          } else if (frame >= Math.floor(i * 0.4)) {
            output += GLYPHS[Math.floor(Math.random() * GLYPHS.length)];
          } else {
            output += "\u00A0";
          }
        }
        setDisplay(output);
        frame++;
        if (frame > len * 1.5 + 14) {
          setDisplay(text);
          if (timerRef.current) clearInterval(timerRef.current);
        }
      }, speed);
    }, delay);

    return () => {
      clearTimeout(timeout);
      if (timerRef.current) if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [children, delay, speed]);

  return (
    <span className={className} style={style}>
      {display || "\u00A0"}
    </span>
  );
}
