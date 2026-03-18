import { getPayload } from "payload";
import config from "@payload-config";
import HomeClient from "@/components/HomeClient";

export const dynamic = "force-dynamic";
import type {
  CMSSiteContent,
  CMSProject,
  CMSOffering,
  CMSService,
  CMSTechnology,
} from "@/lib/cms-types";

export default async function Home() {
  let siteContent: CMSSiteContent | null = null;
  let projects: CMSProject[] = [];
  let offerings: CMSOffering[] = [];
  let services: CMSService[] = [];
  let technologies: CMSTechnology[] = [];

  try {
    const payload = await getPayload({ config });

    // Single fetch — bilingual fields contain both EN and AR
    const siteContentData = await payload.findGlobal({ slug: "site-content" });

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

    siteContent = siteContentData as unknown as CMSSiteContent;
    projects = projectsRes.docs as unknown as CMSProject[];
    offerings = offeringsRes.docs as unknown as CMSOffering[];
    services = servicesRes.docs as unknown as CMSService[];
    technologies = technologiesRes.docs as unknown as CMSTechnology[];
  } catch {
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
