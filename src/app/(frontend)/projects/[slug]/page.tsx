import { getPayload } from "payload";
import config from "@payload-config";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import ProjectDetail from "@/components/sections/ProjectDetail";
import type { CMSProject, CMSMedia } from "@/lib/cms-types";

export const revalidate = 60;

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
      const project = result.docs[0] as unknown as CMSProject;
      const coverImage =
        project.coverImage && typeof project.coverImage === "object"
          ? (project.coverImage as CMSMedia).url
          : undefined;
      return {
        title: `${project.title} | InST`,
        description: project.description,
        openGraph: {
          title: project.title,
          description: project.description,
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

export async function generateStaticParams() {
  try {
    const payload = await getPayload({ config });
    const projects = await payload.find({
      collection: "projects",
      limit: 100,
    });
    return projects.docs
      .filter((p) => p.slug)
      .map((p) => ({ slug: p.slug as string }));
  } catch {
    return [];
  }
}

export default async function ProjectPage({ params }: ProjectPageProps) {
  const { slug } = await params;

  let project: CMSProject | null = null;

  try {
    const payload = await getPayload({ config });
    const result = await payload.find({
      collection: "projects",
      where: { slug: { equals: slug } },
      limit: 1,
      depth: 2,
    });

    if (result.docs.length > 0) {
      project = result.docs[0] as unknown as CMSProject;
    }
  } catch {
    // CMS unavailable
  }

  if (!project) {
    notFound();
  }

  return <ProjectDetail project={project} />;
}
