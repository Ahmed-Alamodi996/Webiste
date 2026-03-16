import { notFound } from "next/navigation";
import { getPayload } from "payload";
import config from "@payload-config";
import PageLayout from "@/components/PageLayout";
import type { Metadata } from "next";
import type {
  CMSPage,
  CMSMedia,
  CMSSiteContent,
  CMSProject,
  CMSOffering,
  CMSService,
  CMSTechnology,
  PageBlock,
} from "@/lib/cms-types";

export const dynamic = "force-dynamic";

interface PageProps {
  params: Promise<{ slug: string[] }>;
}

async function getPage(slugPath: string): Promise<CMSPage | null> {
  try {
    const payload = await getPayload({ config });
    const result = await payload.find({
      collection: "pages",
      where: {
        slug: { equals: slugPath },
        status: { equals: "published" },
      },
      depth: 2,
      limit: 1,
    });
    if (result.docs.length === 0) return null;
    return result.docs[0] as unknown as CMSPage;
  } catch {
    return null;
  }
}

function needsCollection(blocks: PageBlock[], type: string): boolean {
  return blocks.some((b) => b.blockType === type);
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const slugPath = slug.join("/");
  const page = await getPage(slugPath);
  if (!page) return {};

  const ogImage =
    page.meta?.ogImage && typeof page.meta.ogImage === "object"
      ? (page.meta.ogImage as CMSMedia).url
      : undefined;

  return {
    title: page.meta?.metaTitle || page.title,
    description: page.meta?.metaDescription || undefined,
    openGraph: {
      title: page.meta?.metaTitle || page.title,
      description: page.meta?.metaDescription || undefined,
      images: ogImage ? [{ url: ogImage }] : undefined,
    },
  };
}

export default async function DynamicPage({ params }: PageProps) {
  const { slug } = await params;
  const slugPath = slug.join("/");
  const page = await getPage(slugPath);
  if (!page) notFound();

  const blocks = page.layout || [];

  // Determine which collections we need to fetch
  const needsProjects = needsCollection(blocks, "featuredProjects");
  const needsOfferings = needsCollection(blocks, "offerings");
  const needsServices = needsCollection(blocks, "services");
  const needsTechnologies = needsCollection(blocks, "technology");

  let siteContent: { en: CMSSiteContent; ar: CMSSiteContent } | null = null;
  let projects: CMSProject[] = [];
  let offerings: CMSOffering[] = [];
  let services: CMSService[] = [];
  let technologies: CMSTechnology[] = [];

  try {
    const payload = await getPayload({ config });

    // Always fetch site content for i18n
    const [siteContentEn, siteContentAr] = await Promise.all([
      payload.findGlobal({ slug: "site-content", locale: "en" }),
      payload.findGlobal({ slug: "site-content", locale: "ar" }),
    ]);
    siteContent = {
      en: siteContentEn as unknown as CMSSiteContent,
      ar: siteContentAr as unknown as CMSSiteContent,
    };

    // Conditionally fetch collections based on blocks used
    const fetches: Promise<void>[] = [];

    if (needsProjects) {
      fetches.push(
        payload
          .find({ collection: "projects", sort: "order", limit: 100 })
          .then((res) => {
            projects = res.docs as unknown as CMSProject[];
          }),
      );
    }
    if (needsOfferings) {
      fetches.push(
        payload
          .find({ collection: "offerings", sort: "order", limit: 100 })
          .then((res) => {
            offerings = res.docs as unknown as CMSOffering[];
          }),
      );
    }
    if (needsServices) {
      fetches.push(
        payload
          .find({ collection: "services", sort: "order", limit: 100 })
          .then((res) => {
            services = res.docs as unknown as CMSService[];
          }),
      );
    }
    if (needsTechnologies) {
      fetches.push(
        payload
          .find({ collection: "technologies", sort: "order", limit: 100 })
          .then((res) => {
            technologies = res.docs as unknown as CMSTechnology[];
          }),
      );
    }

    await Promise.all(fetches);
  } catch {
    console.warn("Payload CMS unavailable — page will use fallback data.");
  }

  return (
    <PageLayout
      blocks={blocks}
      siteContent={siteContent}
      projects={projects}
      offerings={offerings}
      services={services}
      technologies={technologies}
    />
  );
}
