import Link from "next/link";

export default function NotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center px-6">
      <div className="text-center max-w-md">
        <h1
          className="text-8xl font-bold mb-4"
          style={{
            background: "linear-gradient(135deg, #00C896, #2563EB)",
            WebkitBackgroundClip: "text",
            WebkitTextFillColor: "transparent",
          }}
        >
          404
        </h1>
        <h2
          className="text-2xl font-semibold mb-4"
          style={{ color: "var(--text-primary)" }}
        >
          Page Not Found
        </h2>
        <p
          className="text-base mb-8"
          style={{ color: "var(--text-secondary)" }}
        >
          The page you are looking for does not exist or has been moved.
        </p>
        <Link
          href="/"
          className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-gradient-accent text-white text-sm font-medium transition-all duration-300 hover:shadow-glow hover:scale-[1.02] active:scale-[0.98]"
        >
          Back to Home
        </Link>
      </div>
    </div>
  );
}
