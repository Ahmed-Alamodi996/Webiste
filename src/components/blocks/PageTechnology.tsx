"use client";

import Technology from "@/components/sections/Technology";
import type { CMSTechnology } from "@/lib/cms-types";

interface PageTechnologyProps {
  technologies?: CMSTechnology[];
}

export default function PageTechnology({ technologies }: PageTechnologyProps) {
  return <Technology technologies={technologies} className="py-20" />;
}
