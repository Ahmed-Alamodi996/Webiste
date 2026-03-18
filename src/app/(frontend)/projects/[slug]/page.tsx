import { getPayload } from "payload";
import config from "@payload-config";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import ProjectDetail from "@/components/sections/ProjectDetail";
import type { CMSProjectRaw, CMSMedia } from "@/lib/cms-types";

export const dynamic = "force-dynamic";

interface ProjectPageProps {
  params: Promise<{ slug: string }>;
}

export async function generateMetadata({
  params,
}: ProjectPageProps): Promise<Metadata> {
  const { slug } = await params;
  try {
    const payload = await getPayload({ config });
    const result = await payload.find({
      collection: "projects",
      where: { slug: { equals: slug } },
      limit: 1,
    });
    if (result.docs.length > 0) {
      const project = result.docs[0] as unknown as CMSProjectRaw;
      const coverImage =
        project.coverImage && typeof project.coverImage === "object"
          ? (project.coverImage as CMSMedia).url
          : undefined;
      return {
        title: `${project.title_en || "Project"} | InST`,
        description: project.description_en,
        openGraph: {
          title: project.title_en,
          description: project.description_en,
          type: "article",
          images: coverImage ? [{ url: coverImage }] : undefined,
        },
      };
    }
  } catch {
    // CMS unavailable
  }
  return { title: "Project | InST" };
}

export default async function ProjectPage({ params }: ProjectPageProps) {
  const { slug } = await params;

  let project: CMSProjectRaw | null = null;

  try {
    const payload = await getPayload({ config });
    const result = await payload.find({
      collection: "projects",
      where: { slug: { equals: slug } },
      limit: 1,
      depth: 2,
    });

    if (result.docs.length > 0) {
      project = result.docs[0] as unknown as CMSProjectRaw;
    }
  } catch {
    // CMS unavailable
  }

  if (!project) {
    notFound();
  }

  return <ProjectDetail project={project} />;
}
