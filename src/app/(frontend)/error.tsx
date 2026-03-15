"use client";

export default function Error({
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <html lang="en" data-theme="dark" className="dark">
      <body style={{ backgroundColor: "#0B0F19", margin: 0 }}>
        <div
          style={{
            minHeight: "100vh",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <div style={{ textAlign: "center", padding: "0 1.5rem", maxWidth: "28rem" }}>
            <div
              style={{
                width: "4rem",
                height: "4rem",
                borderRadius: "1rem",
                background: "linear-gradient(135deg, #00C896 0%, #2563EB 100%)",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                margin: "0 auto 1.5rem",
              }}
            >
              <span style={{ color: "white", fontWeight: "bold", fontSize: "1.25rem" }}>!</span>
            </div>
            <h2 style={{ color: "#F9FAFB", fontSize: "1.5rem", fontWeight: 600, marginBottom: "0.75rem" }}>
              Something went wrong
            </h2>
            <p style={{ color: "#9CA3AF", fontSize: "0.875rem", marginBottom: "1.5rem" }}>
              An unexpected error occurred. Please try again.
            </p>
            <button
              onClick={reset}
              style={{
                padding: "0.75rem 1.5rem",
                borderRadius: "9999px",
                background: "linear-gradient(135deg, #00C896 0%, #2563EB 100%)",
                color: "white",
                fontSize: "0.875rem",
                fontWeight: 500,
                border: "none",
                cursor: "pointer",
              }}
            >
              Try Again
            </button>
          </div>
        </div>
      </body>
    </html>
  );
}
