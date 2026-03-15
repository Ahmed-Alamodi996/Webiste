import { getPayload } from "payload";
import config from "@payload-config";
import type { MetadataRoute } from "next";

const BASE_URL = process.env.NEXT_PUBLIC_SITE_URL || "https://inst.tech";

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const routes: MetadataRoute.Sitemap = [
    {
      url: BASE_URL,
      lastModified: new Date(),
      changeFrequency: "weekly",
      priority: 1,
    },
  ];

  try {
    const payload = await getPayload({ config });

    // Add project pages
    const projects = await payload.find({
      collection: "projects",
      limit: 1000,
    });
    for (const project of projects.docs) {
      if (project.slug) {
        routes.push({
          url: `${BASE_URL}/projects/${project.slug}`,
          lastModified: new Date(project.updatedAt || Date.now()),
          changeFrequency: "monthly",
          priority: 0.7,
        });
      }
    }

    // Add CMS pages
    const pages = await payload.find({
      collection: "pages",
      where: { status: { equals: "published" } },
      limit: 1000,
    });
    for (const page of pages.docs) {
      if (page.slug) {
        routes.push({
          url: `${BASE_URL}/${page.slug}`,
          lastModified: new Date(page.updatedAt || Date.now()),
          changeFrequency: "monthly",
          priority: 0.6,
        });
      }
    }
  } catch {
    // CMS unavailable — return static routes only
  }

  return routes;
}
