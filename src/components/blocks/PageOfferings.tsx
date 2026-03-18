"use client";

import WhatWeOffer from "@/components/sections/WhatWeOffer";

interface PageOfferingsProps {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  offerings?: any[];
}

export default function PageOfferings({ offerings }: PageOfferingsProps) {
  return <WhatWeOffer offerings={offerings} className="py-20" />;
}
