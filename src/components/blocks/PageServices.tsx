"use client";

import OurServices from "@/components/sections/OurServices";

interface PageServicesProps {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  services?: any[];
}

export default function PageServices({ services }: PageServicesProps) {
  return <OurServices services={services} className="py-20" />;
}
