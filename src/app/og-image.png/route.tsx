import { ImageResponse } from "next/og";

export const runtime = "edge";

export async function GET() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          background: "linear-gradient(135deg, #0B0F19 0%, #060A12 50%, #0A1F44 100%)",
          position: "relative",
        }}
      >
        {/* Background glow */}
        <div
          style={{
            position: "absolute",
            top: "50%",
            left: "50%",
            transform: "translate(-50%, -50%)",
            width: "600px",
            height: "600px",
            borderRadius: "50%",
            background: "radial-gradient(circle, rgba(0, 200, 150, 0.15) 0%, transparent 70%)",
          }}
        />

        {/* Logo */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: "16px",
            marginBottom: "32px",
          }}
        >
          <div
            style={{
              width: "72px",
              height: "72px",
              borderRadius: "18px",
              background: "linear-gradient(135deg, #00C896 0%, #2563EB 100%)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontWeight: "bold",
              fontSize: "32px",
              color: "white",
            }}
          >
            In
          </div>
          <span
            style={{
              fontSize: "48px",
              fontWeight: 600,
              color: "#F9FAFB",
              letterSpacing: "-0.02em",
            }}
          >
            ST
          </span>
        </div>

        {/* Tagline */}
        <div
          style={{
            fontSize: "28px",
            color: "#9CA3AF",
            textAlign: "center",
            maxWidth: "700px",
            lineHeight: 1.4,
          }}
        >
          Engineering the future of intelligent solutions
        </div>

        {/* Accent line */}
        <div
          style={{
            width: "120px",
            height: "3px",
            background: "linear-gradient(90deg, #00C896, #2563EB)",
            borderRadius: "2px",
            marginTop: "32px",
          }}
        />

        {/* Bottom URL */}
        <div
          style={{
            position: "absolute",
            bottom: "40px",
            fontSize: "18px",
            color: "#6B7280",
            letterSpacing: "0.1em",
          }}
        >
          inst.tech
        </div>
      </div>
    ),
    {
      width: 1200,
      height: 630,
    }
  );
}
