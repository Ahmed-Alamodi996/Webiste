"use client";

import { motion } from "framer-motion";
import { RichTextContent } from "@/components/ui/RichTextContent";
import type { RichTextBlockData } from "@/lib/cms-types";

const maxWidthMap: Record<string, string> = {
  prose: "max-w-prose",
  "3xl": "max-w-3xl",
  full: "max-w-full",
};

export default function RichTextSection({ block }: { block: RichTextBlockData }) {
  const widthClass = maxWidthMap[block.maxWidth || "prose"] || "max-w-prose";

  return (
    <motion.section
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-100px" }}
      transition={{ duration: 0.6, ease: [0.19, 1, 0.22, 1] }}
      className={`${widthClass} mx-auto px-6 py-16`}
    >
      <RichTextContent data={block.content} />
    </motion.section>
  );
}
