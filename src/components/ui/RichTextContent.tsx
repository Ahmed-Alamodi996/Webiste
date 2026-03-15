"use client";

import Image from "next/image";

export interface LexicalNode {
  type: string;
  tag?: string;
  format?: number | string;
  text?: string;
  children?: LexicalNode[];
  listType?: string;
  url?: string;
  newTab?: boolean;
  fields?: { url?: string; newTab?: boolean };
  indent?: number;
  value?: { url?: string; alt?: string; width?: number; height?: number };
  relationTo?: string;
}

export function RichTextContent({
  data,
  accentColor = "var(--brand-green)",
}: {
  data: Record<string, unknown>;
  accentColor?: string;
}) {
  const root = data.root as LexicalNode | undefined;
  if (!root?.children) return null;

  return (
    <div
      className="prose prose-lg max-w-none"
      style={{
        color: "var(--text-secondary)",
        ["--tw-prose-headings" as string]: "var(--text-primary)",
        ["--tw-prose-links" as string]: accentColor,
        ["--tw-prose-bold" as string]: "var(--text-primary)",
      }}
    >
      {root.children.map((node, i) => (
        <RichTextNode key={i} node={node} />
      ))}
    </div>
  );
}

export function RichTextNode({ node }: { node: LexicalNode }) {
  // Text leaf
  if (node.type === "text") {
    let content: React.ReactNode = node.text || "";
    const format = typeof node.format === "number" ? node.format : 0;
    if (format & 1) content = <strong>{content}</strong>;
    if (format & 2) content = <em>{content}</em>;
    if (format & 8) content = <u>{content}</u>;
    if (format & 4) content = <s>{content}</s>;
    if (format & 16)
      content = (
        <code className="px-1.5 py-0.5 rounded glass text-sm font-mono">
          {content}
        </code>
      );
    return <>{content}</>;
  }

  // Linebreak
  if (node.type === "linebreak") return <br />;

  // Tab
  if (node.type === "tab") return <>&emsp;</>;

  const children = node.children?.map((child, i) => (
    <RichTextNode key={i} node={child} />
  ));

  // Paragraph
  if (node.type === "paragraph") {
    return <p>{children}</p>;
  }

  // Heading
  if (node.type === "heading") {
    const tag = node.tag || "h2";
    switch (tag) {
      case "h1":
        return <h1>{children}</h1>;
      case "h3":
        return <h3>{children}</h3>;
      case "h4":
        return <h4>{children}</h4>;
      case "h5":
        return <h5>{children}</h5>;
      case "h6":
        return <h6>{children}</h6>;
      default:
        return <h2>{children}</h2>;
    }
  }

  // List
  if (node.type === "list") {
    return node.listType === "number" ? (
      <ol>{children}</ol>
    ) : (
      <ul>{children}</ul>
    );
  }

  // List item
  if (node.type === "listitem") {
    return <li>{children}</li>;
  }

  // Link
  if (node.type === "link") {
    const url = node.fields?.url || node.url || "#";
    const newTab = node.fields?.newTab ?? node.newTab;
    return (
      <a
        href={url}
        {...(newTab ? { target: "_blank", rel: "noopener noreferrer" } : {})}
      >
        {children}
      </a>
    );
  }

  // Quote
  if (node.type === "quote") {
    return <blockquote>{children}</blockquote>;
  }

  // Horizontal rule
  if (node.type === "horizontalrule") {
    return <hr />;
  }

  // Upload (inline image)
  if (node.type === "upload" && node.value) {
    return (
      <figure className="my-6">
        <Image
          src={node.value.url || ""}
          alt={node.value.alt || ""}
          width={node.value.width || 800}
          height={node.value.height || 450}
          className="rounded-xl w-full h-auto"
        />
      </figure>
    );
  }

  // Fallback: render children
  return <>{children}</>;
}
