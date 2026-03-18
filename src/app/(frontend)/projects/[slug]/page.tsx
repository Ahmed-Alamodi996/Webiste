import { getPayload } from "payload";
import config from "@payload-config";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import ProjectDetail from "@/components/sections/ProjectDetail";
import type { CMSProjectRaw, CMSMedia } from "@/lib/cms-types";

export const dynamic = "force-dynamic";

const BASE_URL = process.env.NEXT_PUBLIC_SITE_URL || "https://inst-sa.com";

interface ProjectPageProps {
  params: Promise<{ slug: string }>;
}

async function getProject(slug: string): Promise<CMSProjectRaw | null> {
  try {
    const payload = await getPayload({ config });
    const result = await payload.find({
      collection: "projects",
      where: { slug: { equals: slug } },
      limit: 1,
      depth: 2,
    });
    if (result.docs.length > 0) {
      return result.docs[0] as unknown as CMSProjectRaw;
    }
  } catch {
    // CMS unavailable
  }
  return null;
}

export async function generateMetadata({ params }: ProjectPageProps): Promise<Metadata> {
  const { slug } = await params;
  const project = await getProject(slug);

  if (!project) return { title: "Project | InST" };

  const coverImage = project.coverImage && typeof project.coverImage === "object"
    ? (project.coverImage as CMSMedia).url
    : undefined;

  const title = [project.title_en, project.title_ar].filter(Boolean).join(" | ");
  const description = [project.description_en, project.description_ar].filter(Boolean).join(" — ");

  return {
    title: `${title} | InST`,
    description,
    alternates: {
      canonical: `${BASE_URL}/projects/${slug}`,
    },
    openGraph: {
      title: `${title} | InST`,
      description,
      type: "article",
      url: `${BASE_URL}/projects/${slug}`,
      images: coverImage ? [{ url: coverImage, width: 1200, height: 630, alt: title }] : undefined,
    },
    twitter: {
      card: "summary_large_image",
      title: `${title} | InST`,
      description,
      images: coverImage ? [coverImage] : undefined,
    },
  };
}

export default async function ProjectPage({ params }: ProjectPageProps) {
  const { slug } = await params;
  const project = await getProject(slug);

  if (!project) notFound();

  // JSON-LD structured data for this project
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "CreativeWork",
    name: project.title_en || "",
    alternateName: project.title_ar || undefined,
    description: project.description_en || "",
    url: `${BASE_URL}/projects/${slug}`,
    creator: {
      "@type": "Organization",
      name: "Innovative Solutions Tech",
      alternateName: ["InST", "انوفيتيف سلوشنز تيك"],
      url: BASE_URL,
    },
    genre: project.category_en || "",
    inLanguage: ["en", "ar"],
    ...(project.coverImage && typeof project.coverImage === "object"
      ? { image: (project.coverImage as CMSMedia).url }
      : {}),
    ...(project.techStack?.length
      ? { keywords: project.techStack.map((t) => t.name).join(", ") }
      : {}),
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <ProjectDetail project={project} />
    </>
  );
}
