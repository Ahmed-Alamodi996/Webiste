"use client";

import WhatWeOffer from "@/components/sections/WhatWeOffer";
import type { CMSOffering } from "@/lib/cms-types";

interface PageOfferingsProps {
  offerings?: CMSOffering[];
}

export default function PageOfferings({ offerings }: PageOfferingsProps) {
  return <WhatWeOffer offerings={offerings} className="py-20" />;
}
