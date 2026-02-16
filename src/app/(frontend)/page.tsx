import { getPayload } from "payload";
import config from "@payload-config";
import HomeClient from "@/components/HomeClient";
import type {
  CMSSiteContent,
  CMSProject,
  CMSOffering,
  CMSService,
  CMSTechnology,
} from "@/lib/cms-types";

export default async function Home() {
  let siteContent: { en: CMSSiteContent; ar: CMSSiteContent } | null = null;
  let projects: CMSProject[] = [];
  let offerings: CMSOffering[] = [];
  let services: CMSService[] = [];
  let technologies: CMSTechnology[] = [];

  try {
    const payload = await getPayload({ config });

    const [siteContentEn, siteContentAr] = await Promise.all([
      payload.findGlobal({ slug: "site-content", locale: "en" }),
      payload.findGlobal({ slug: "site-content", locale: "ar" }),
    ]);

    const [projectsRes, offeringsRes, servicesRes, technologiesRes] =
      await Promise.all([
        payload.find({ collection: "projects", sort: "order", limit: 100 }),
        payload.find({ collection: "offerings", sort: "order", limit: 100 }),
        payload.find({ collection: "services", sort: "order", limit: 100 }),
        payload.find({
          collection: "technologies",
          sort: "order",
          limit: 100,
        }),
      ]);

    siteContent = {
      en: siteContentEn as unknown as CMSSiteContent,
      ar: siteContentAr as unknown as CMSSiteContent,
    };
    projects = projectsRes.docs as unknown as CMSProject[];
    offerings = offeringsRes.docs as unknown as CMSOffering[];
    services = servicesRes.docs as unknown as CMSService[];
    technologies = technologiesRes.docs as unknown as CMSTechnology[];
  } catch {
    // If CMS is unavailable (no MongoDB, etc.), fall through with null/empty data.
    // LanguageProvider and section components will use static fallbacks.
    console.warn(
      "Payload CMS unavailable — using static fallback data."
    );
  }

  return (
    <HomeClient
      siteContent={siteContent}
      projects={projects}
      offerings={offerings}
      services={services}
      technologies={technologies}
    />
  );
}
