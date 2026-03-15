import { getPayload } from "payload";
import config from "@payload-config";
import { NextResponse } from "next/server";

// Simple in-memory rate limiter (per IP, 5 requests per minute)
const rateLimit = new Map<string, { count: number; resetTime: number }>();
const RATE_LIMIT_MAX = 5;
const RATE_LIMIT_WINDOW = 60 * 1000; // 1 minute

function isRateLimited(ip: string): boolean {
  const now = Date.now();
  const entry = rateLimit.get(ip);

  // Clean stale entries to prevent memory leak
  if (rateLimit.size > 10000) {
    for (const [key, val] of rateLimit) {
      if (now > val.resetTime) rateLimit.delete(key);
    }
  }

  if (!entry || now > entry.resetTime) {
    rateLimit.set(ip, { count: 1, resetTime: now + RATE_LIMIT_WINDOW });
    return false;
  }

  entry.count++;
  return entry.count > RATE_LIMIT_MAX;
}

export async function POST(request: Request) {
  try {
    // Rate limiting
    const forwarded = request.headers.get("x-forwarded-for");
    const ip = forwarded?.split(",")[0]?.trim() || "unknown";
    if (isRateLimited(ip)) {
      return NextResponse.json(
        { error: "Too many requests. Please try again later." },
        { status: 429 }
      );
    }

    const body = await request.json();
    const { name, email, message } = body;

    // Presence validation
    if (!name || !email || !message) {
      return NextResponse.json(
        { error: "All fields are required" },
        { status: 400 }
      );
    }

    // Type validation
    if (typeof name !== "string" || typeof email !== "string" || typeof message !== "string") {
      return NextResponse.json(
        { error: "Invalid field types" },
        { status: 400 }
      );
    }

    // Length validation
    const trimmedName = name.trim();
    const trimmedEmail = email.trim();
    const trimmedMessage = message.trim();

    if (trimmedName.length === 0 || trimmedEmail.length === 0 || trimmedMessage.length === 0) {
      return NextResponse.json(
        { error: "All fields are required" },
        { status: 400 }
      );
    }

    if (trimmedName.length > 200) {
      return NextResponse.json(
        { error: "Name must be 200 characters or less" },
        { status: 400 }
      );
    }

    if (trimmedEmail.length > 254) {
      return NextResponse.json(
        { error: "Email must be 254 characters or less" },
        { status: 400 }
      );
    }

    if (trimmedMessage.length < 10) {
      return NextResponse.json(
        { error: "Message must be at least 10 characters" },
        { status: 400 }
      );
    }

    if (trimmedMessage.length > 5000) {
      return NextResponse.json(
        { error: "Message must be 5000 characters or less" },
        { status: 400 }
      );
    }

    // Email format validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(trimmedEmail)) {
      return NextResponse.json(
        { error: "Invalid email address" },
        { status: 400 }
      );
    }

    const payload = await getPayload({ config });

    await payload.create({
      collection: "form-submissions",
      data: {
        name: trimmedName,
        email: trimmedEmail,
        message: trimmedMessage,
      },
    });

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("Contact form submission error:", error);
    return NextResponse.json(
      { error: "Failed to submit form" },
      { status: 500 }
    );
  }
}

export async function OPTIONS() {
  return new NextResponse(null, {
    status: 204,
    headers: {
      "Allow": "POST, OPTIONS",
    },
  });
}
