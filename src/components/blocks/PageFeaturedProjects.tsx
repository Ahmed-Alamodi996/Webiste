"use client";

import FeaturedProjects from "@/components/sections/FeaturedProjects";

interface PageFeaturedProjectsProps {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  projects?: any[];
}

export default function PageFeaturedProjects({ projects }: PageFeaturedProjectsProps) {
  return <FeaturedProjects projects={projects} className="py-20" />;
}
