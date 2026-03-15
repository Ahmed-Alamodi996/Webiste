import type { SpacerBlockData } from "@/lib/cms-types";

const sizeMap: Record<string, string> = {
  sm: "h-8",
  md: "h-16",
  lg: "h-24",
  xl: "h-40",
};

export default function Spacer({ block }: { block: SpacerBlockData }) {
  return <div className={sizeMap[block.size] || "h-16"} aria-hidden />;
}
