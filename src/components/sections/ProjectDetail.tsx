"use client";

import { motion } from "framer-motion";
import { ArrowLeft, ExternalLink, Play } from "lucide-react";
import Link from "next/link";
import Image from "next/image";
import { useState } from "react";
import type { CMSProjectRaw, CMSProject, CMSMedia } from "@/lib/cms-types";
import { resolveProject } from "@/lib/cms-types";
import CustomCursor from "@/components/layout/CustomCursor";
import { RichTextContent } from "@/components/ui/RichTextContent";
import { useLanguage } from "@/context/LanguageContext";

interface ProjectDetailProps {
  project: CMSProjectRaw;
}

/** Type-guard: is the upload field a populated media object (not just an ID string)? */
function isMedia(val: CMSMedia | string | undefined): val is CMSMedia {
  return typeof val === "object" && val !== null && "url" in val;
}

/** Extract a YouTube embed URL from a regular or short URL */
function getYouTubeEmbedUrl(url: string): string | null {
  const match = url.match(
    /(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([\w-]+)/,
  );
  return match ? `https://www.youtube.com/embed/${match[1]}` : null;
}

/** Extract a Vimeo embed URL */
function getVimeoEmbedUrl(url: string): string | null {
  const match = url.match(/vimeo\.com\/(\d+)/);
  return match ? `https://player.vimeo.com/video/${match[1]}` : null;
}

const ease = [0.19, 1, 0.22, 1] as const;

/** Sanitize a hex color value to prevent CSS injection */
function sanitizeHexColor(color: string | undefined): string {
  if (!color) return "#888888";
  return /^#[0-9A-Fa-f]{6}$/.test(color) ? color : "#888888";
}

export default function ProjectDetail({ project: rawProject }: ProjectDetailProps) {
  const { locale } = useLanguage();
  const project = resolveProject(rawProject, locale);
  const safeAccent = sanitizeHexColor(project.accentColor);
  const hasCover = isMedia(project.coverImage);
  const hasGallery =
    project.gallery &&
    project.gallery.length > 0 &&
    project.gallery.some((g) => isMedia(g.image));
  const hasTechStack = project.techStack && project.techStack.length > 0;
  const hasVideo = project.video?.url;
  const hasContent =
    project.content &&
    typeof project.content === "object" &&
    "root" in project.content;

  return (
    <div
      className="min-h-screen relative overflow-hidden"
      style={{ backgroundColor: "var(--bg-primary)" }}
    >
      <CustomCursor />

      {/* Background accent */}
      <div
        className="absolute top-0 left-0 right-0 h-[400px] opacity-20"
        style={{
          background: `radial-gradient(ellipse 80% 60% at 50% 0%, ${safeAccent}30, transparent)`,
        }}
      />

      {/* Top accent line */}
      <div
        className="absolute top-0 left-0 right-0 h-[2px] z-10"
        style={{
          background: `linear-gradient(90deg, transparent, ${safeAccent}, transparent)`,
        }}
      />

      {/* Content */}
      <div className="relative z-10 max-w-5xl mx-auto px-4 sm:px-6 py-16 sm:py-20">
        {/* Back link */}
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5, ease }}
        >
          <Link
            href="/#projects"
            className="inline-flex items-center gap-2 text-sm font-medium mb-12 transition-colors duration-300 group"
            style={{ color: "var(--text-secondary)" }}
          >
            <ArrowLeft
              size={16}
              className="group-hover:-translate-x-1 transition-transform duration-300"
            />
            Back to Projects
          </Link>
        </motion.div>

        {/* Category badge */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.1, ease }}
        >
          <span
            className="inline-block px-4 py-2 rounded-full text-xs font-mono uppercase tracking-wider glass mb-6"
            style={{ color: safeAccent }}
          >
            {project.category}
          </span>
        </motion.div>

        {/* Title */}
        <motion.h1
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.15, ease }}
          className="text-display-xl mb-6"
          style={{ color: "var(--text-primary)" }}
        >
          {project.title}
        </motion.h1>

        {/* Stat */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.25, ease }}
          className="flex items-baseline gap-3 mb-8"
        >
          <span
            className="text-3xl sm:text-5xl md:text-6xl font-bold"
            style={{ color: safeAccent }}
          >
            {project.stat}
          </span>
          <span className="text-lg" style={{ color: "var(--text-secondary)" }}>
            {project.statLabel}
          </span>
        </motion.div>

        {/* Tech stack badges */}
        {hasTechStack && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.28, ease }}
            className="flex flex-wrap gap-2 mb-8"
          >
            {project.techStack!.map((tech, i) => (
              <span
                key={i}
                className="px-3 py-1.5 rounded-full text-xs font-mono font-medium border"
                style={{
                  color: tech.color || safeAccent,
                  borderColor: `${tech.color || safeAccent}30`,
                  backgroundColor: `${tech.color || safeAccent}10`,
                }}
              >
                {tech.name}
              </span>
            ))}
          </motion.div>
        )}

        {/* Divider */}
        <motion.div
          initial={{ scaleX: 0 }}
          animate={{ scaleX: 1 }}
          transition={{ duration: 0.8, delay: 0.3, ease }}
          className="w-full h-[1px] mb-10 origin-left"
          style={{
            background: `linear-gradient(90deg, ${safeAccent}40, transparent)`,
          }}
        />

        {/* Description */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.35, ease }}
          className="mb-12"
        >
          <p
            className="text-lg leading-relaxed max-w-3xl"
            style={{ color: "var(--text-secondary)" }}
          >
            {project.description}
          </p>
        </motion.div>

        {/* Cover image */}
        {hasCover && (
          <motion.div
            initial={{ opacity: 0, y: 30, scale: 0.97 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            transition={{ duration: 0.8, delay: 0.4, ease }}
            className="rounded-2xl overflow-hidden mb-12 glow-border"
          >
            <Image
              src={(project.coverImage as CMSMedia).url}
              alt={(project.coverImage as CMSMedia).alt || project.title}
              width={(project.coverImage as CMSMedia).width || 1920}
              height={(project.coverImage as CMSMedia).height || 1080}
              className="w-full h-auto object-cover"
              priority
            />
          </motion.div>
        )}

        {/* Fallback visual card if no cover image */}
        {!hasCover && (
          <motion.div
            initial={{ opacity: 0, y: 30, scale: 0.97 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            transition={{ duration: 0.8, delay: 0.4, ease }}
            className="rounded-3xl overflow-hidden glass glow-border p-10 md:p-14 relative mb-12"
          >
            <div
              className={`absolute inset-0 bg-gradient-to-br ${project.gradient} opacity-20`}
            />
            <div className="absolute inset-0 bg-grid-dense opacity-10" />
            <div className="relative z-10 text-center">
              <div
                className="text-[4rem] sm:text-[6rem] md:text-[10rem] font-bold leading-none mb-6"
                style={{ color: safeAccent, opacity: 0.15 }}
              >
                {project.stat}
              </div>
              <p
                className="text-sm font-mono uppercase tracking-widest"
                style={{ color: "var(--text-muted)" }}
              >
                {project.statLabel}
              </p>
            </div>
          </motion.div>
        )}

        {/* Rich text content */}
        {hasContent && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.45, ease }}
            className="mb-12"
          >
            <RichTextContent data={project.content!} accentColor={safeAccent} />
          </motion.div>
        )}

        {/* Video embed */}
        {hasVideo && (
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, delay: 0.5, ease }}
            className="mb-12"
          >
            <VideoEmbed
              url={project.video!.url!}
              provider={project.video!.provider}
              accentColor={safeAccent}
            />
          </motion.div>
        )}

        {/* Image gallery */}
        {hasGallery && (
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, delay: 0.55, ease }}
            className="mb-12"
          >
            <h2
              className="text-2xl font-bold mb-6"
              style={{ color: "var(--text-primary)" }}
            >
              Gallery
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {project.gallery!.map((item, i) => {
                if (!isMedia(item.image)) return null;
                return (
                  <div
                    key={i}
                    className="rounded-xl overflow-hidden glow-border"
                  >
                    <Image
                      src={item.image.url}
                      alt={item.image.alt || `${project.title} screenshot ${i + 1}`}
                      width={item.image.width || 960}
                      height={item.image.height || 540}
                      className="w-full h-auto object-cover hover:scale-105 transition-transform duration-500"
                    />
                  </div>
                );
              })}
            </div>
          </motion.div>
        )}

        {/* CTA */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6, duration: 0.5 }}
          className="mt-12 flex flex-wrap items-center gap-4"
        >
          <Link
            href="/#projects"
            className="px-6 py-3 rounded-full glass glow-border glow-border-hover text-sm font-medium transition-all duration-300 inline-flex items-center gap-2"
            style={{ color: "var(--text-primary)" }}
          >
            <ArrowLeft size={16} />
            All Projects
          </Link>
          {project.liveUrl ? (
            <a
              href={project.liveUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="px-6 py-3 rounded-full bg-gradient-accent text-white text-sm font-medium transition-all duration-300 inline-flex items-center gap-2 hover:shadow-glow"
            >
              View Live Project
              <ExternalLink size={14} />
            </a>
          ) : (
            <Link
              href="/#contact"
              className="px-6 py-3 rounded-full bg-gradient-accent text-white text-sm font-medium transition-all duration-300 inline-flex items-center gap-2 hover:shadow-glow"
            >
              Get in Touch
              <ExternalLink size={14} />
            </Link>
          )}
        </motion.div>
      </div>
    </div>
  );
}

/* ---------- Video Embed ---------- */

function VideoEmbed({
  url,
  provider,
  accentColor,
}: {
  url: string;
  provider?: "youtube" | "vimeo" | "direct";
  accentColor: string;
}) {
  const [playing, setPlaying] = useState(false);

  // YouTube
  if (provider === "youtube" || (!provider && url.includes("youtu"))) {
    const embedUrl = getYouTubeEmbedUrl(url);
    if (!embedUrl) return null;
    return (
      <div className="rounded-2xl overflow-hidden glow-border">
        {!playing ? (
          <button
            onClick={() => setPlaying(true)}
            className="relative w-full aspect-video group cursor-pointer"
            style={{ backgroundColor: "var(--bg-secondary)" }}
          >
            <div className="absolute inset-0 flex items-center justify-center">
              <div
                className="w-16 h-16 rounded-full flex items-center justify-center transition-transform duration-300 group-hover:scale-110"
                style={{ backgroundColor: accentColor }}
              >
                <Play size={24} className="text-white ml-1" fill="white" />
              </div>
            </div>
            <span
              className="absolute bottom-4 left-4 text-sm font-mono"
              style={{ color: "var(--text-muted)" }}
            >
              Play Video
            </span>
          </button>
        ) : (
          <iframe
            src={`${embedUrl}?autoplay=1`}
            className="w-full aspect-video"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
            title="Project video"
          />
        )}
      </div>
    );
  }

  // Vimeo
  if (provider === "vimeo" || url.includes("vimeo")) {
    const embedUrl = getVimeoEmbedUrl(url);
    if (!embedUrl) return null;
    return (
      <div className="rounded-2xl overflow-hidden glow-border">
        <iframe
          src={embedUrl}
          className="w-full aspect-video"
          allow="autoplay; fullscreen; picture-in-picture"
          allowFullScreen
          title="Project video"
        />
      </div>
    );
  }

  // Direct video
  return (
    <div className="rounded-2xl overflow-hidden glow-border">
      <video
        src={url}
        controls
        className="w-full aspect-video"
        style={{ backgroundColor: "var(--bg-secondary)" }}
      >
        Your browser does not support the video tag.
      </video>
    </div>
  );
}
