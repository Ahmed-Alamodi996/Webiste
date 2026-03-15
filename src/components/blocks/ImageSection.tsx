"use client";

import { motion } from "framer-motion";
import Image from "next/image";
import type { ImageBlockData, CMSMedia } from "@/lib/cms-types";

function isMedia(val: CMSMedia | string | undefined): val is CMSMedia {
  return typeof val === "object" && val !== null && "url" in val;
}

const sizeMap: Record<string, string> = {
  small: "max-w-2xl",
  medium: "max-w-5xl",
  full: "max-w-full",
};

export default function ImageSection({ block }: { block: ImageBlockData }) {
  if (!isMedia(block.image)) return null;
  const media = block.image as CMSMedia;
  const widthClass = sizeMap[block.size || "medium"] || "max-w-5xl";

  return (
    <motion.figure
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-100px" }}
      transition={{ duration: 0.7, ease: [0.19, 1, 0.22, 1] }}
      className={`${widthClass} mx-auto px-6 py-8`}
    >
      <div className="rounded-2xl overflow-hidden glow-border">
        <Image
          src={media.url}
          alt={media.alt || media.filename || "Image"}
          width={media.width || 1920}
          height={media.height || 1080}
          className="w-full h-auto object-cover"
        />
      </div>
      {block.caption && (
        <figcaption
          className="text-sm mt-3 text-center"
          style={{ color: "var(--text-muted)" }}
        >
          {block.caption}
        </figcaption>
      )}
    </motion.figure>
  );
}
