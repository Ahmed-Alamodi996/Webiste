"use client";

import OurServices from "@/components/sections/OurServices";
import type { CMSService } from "@/lib/cms-types";

interface PageServicesProps {
  services?: CMSService[];
}

export default function PageServices({ services }: PageServicesProps) {
  return <OurServices services={services} className="py-20" />;
}
