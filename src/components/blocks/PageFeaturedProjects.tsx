"use client";

import FeaturedProjects from "@/components/sections/FeaturedProjects";
import type { CMSProject } from "@/lib/cms-types";

interface PageFeaturedProjectsProps {
  projects?: CMSProject[];
}

export default function PageFeaturedProjects({ projects }: PageFeaturedProjectsProps) {
  return <FeaturedProjects projects={projects} className="py-20" />;
}
