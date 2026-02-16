"use client";

import { useState, useRef } from "react";
import { motion } from "framer-motion";
import { fadeInUp, slideInLeft, slideInRight } from "@/lib/animations";
import { Send, CheckCircle, MapPin, Mail, Phone } from "lucide-react";
import { cn } from "@/lib/utils";

export default function Contact() {
  const [formState, setFormState] = useState({
    name: "",
    email: "",
    message: "",
  });
  const [submitted, setSubmitted] = useState(false);
  const [focused, setFocused] = useState<string | null>(null);
  const formRef = useRef<HTMLFormElement>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitted(true);
    setTimeout(() => {
      setSubmitted(false);
      setFormState({ name: "", email: "", message: "" });
    }, 3000);
  };

  const handleRipple = (e: React.MouseEvent<HTMLButtonElement>) => {
    const button = e.currentTarget;
    const rect = button.getBoundingClientRect();
    const ripple = document.createElement("span");
    const size = Math.max(rect.width, rect.height);
    ripple.style.width = ripple.style.height = `${size}px`;
    ripple.style.left = `${e.clientX - rect.left - size / 2}px`;
    ripple.style.top = `${e.clientY - rect.top - size / 2}px`;
    ripple.className = "ripple";
    button.appendChild(ripple);
    setTimeout(() => ripple.remove(), 600);
  };

  return (
    <section id="contact" className="relative section-padding overflow-hidden">
      <div className="absolute inset-0 bg-grid opacity-20" />
      <div className="gradient-blob absolute -right-40 bottom-0 h-[500px] w-[500px] bg-primary/10" />
      <div className="gradient-blob absolute -left-40 top-0 h-[400px] w-[400px] bg-accent/8" />

      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        {/* Header */}
        <motion.div
          variants={fadeInUp}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.3 }}
          className="mb-16 text-center"
        >
          <span className="mb-4 inline-block text-sm font-medium tracking-wider text-primary uppercase">
            Get In Touch
          </span>
          <h2 className="text-3xl font-bold tracking-tight md:text-5xl">
            Let&apos;s build something{" "}
            <span className="gradient-text">extraordinary</span>
          </h2>
          <p className="mx-auto mt-4 max-w-xl text-lg text-muted">
            Ready to transform your vision into reality? We&apos;d love to hear
            from you.
          </p>
        </motion.div>

        <div className="grid gap-12 lg:grid-cols-5">
          {/* Info */}
          <motion.div
            variants={slideInLeft}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, amount: 0.3 }}
            className="lg:col-span-2"
          >
            <div className="space-y-8">
              <div>
                <h3 className="mb-4 text-xl font-semibold">
                  Start a conversation
                </h3>
                <p className="text-sm leading-relaxed text-muted">
                  Whether you have a project in mind, need technical
                  consultation, or want to explore a partnership — our team is
                  ready to help.
                </p>
              </div>

              <div className="space-y-4">
                {[
                  {
                    icon: Mail,
                    label: "Email",
                    value: "hello@inst.tech",
                  },
                  {
                    icon: Phone,
                    label: "Phone",
                    value: "+1 (555) 000-0000",
                  },
                  {
                    icon: MapPin,
                    label: "Location",
                    value: "San Francisco, CA",
                  },
                ].map((item) => (
                  <div key={item.label} className="flex items-center gap-4">
                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-white/10 bg-surface">
                      <item.icon className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <p className="text-xs text-muted">{item.label}</p>
                      <p className="text-sm font-medium">{item.value}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </motion.div>

          {/* Form */}
          <motion.div
            variants={slideInRight}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, amount: 0.3 }}
            className="lg:col-span-3"
          >
            <div className="relative rounded-2xl border border-white/[0.06] bg-surface/50 p-8 backdrop-blur-sm">
              {/* Success overlay */}
              {submitted && (
                <motion.div
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  className="absolute inset-0 z-10 flex flex-col items-center justify-center rounded-2xl bg-surface/95 backdrop-blur-sm"
                >
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{
                      type: "spring",
                      stiffness: 200,
                      damping: 15,
                    }}
                  >
                    <CheckCircle className="h-16 w-16 text-primary" />
                  </motion.div>
                  <p className="mt-4 text-lg font-semibold">Message Sent!</p>
                  <p className="mt-1 text-sm text-muted">
                    We&apos;ll get back to you within 24 hours.
                  </p>
                </motion.div>
              )}

              <form
                ref={formRef}
                onSubmit={handleSubmit}
                className="space-y-5"
              >
                {/* Name */}
                <div className="relative">
                  <label
                    htmlFor="name"
                    className={cn(
                      "absolute left-4 transition-all duration-300 pointer-events-none",
                      focused === "name" || formState.name
                        ? "-top-2.5 text-xs text-primary bg-surface/50 px-1"
                        : "top-3.5 text-sm text-muted"
                    )}
                  >
                    Your Name
                  </label>
                  <input
                    id="name"
                    type="text"
                    required
                    value={formState.name}
                    onChange={(e) =>
                      setFormState({ ...formState, name: e.target.value })
                    }
                    onFocus={() => setFocused("name")}
                    onBlur={() => setFocused(null)}
                    className="w-full rounded-xl border border-white/10 bg-background/50 px-4 py-3.5 text-sm text-foreground transition-all duration-300 hover:border-white/20 focus:border-primary/50"
                  />
                </div>

                {/* Email */}
                <div className="relative">
                  <label
                    htmlFor="email"
                    className={cn(
                      "absolute left-4 transition-all duration-300 pointer-events-none",
                      focused === "email" || formState.email
                        ? "-top-2.5 text-xs text-primary bg-surface/50 px-1"
                        : "top-3.5 text-sm text-muted"
                    )}
                  >
                    Email Address
                  </label>
                  <input
                    id="email"
                    type="email"
                    required
                    value={formState.email}
                    onChange={(e) =>
                      setFormState({ ...formState, email: e.target.value })
                    }
                    onFocus={() => setFocused("email")}
                    onBlur={() => setFocused(null)}
                    className="w-full rounded-xl border border-white/10 bg-background/50 px-4 py-3.5 text-sm text-foreground transition-all duration-300 hover:border-white/20 focus:border-primary/50"
                  />
                </div>

                {/* Message */}
                <div className="relative">
                  <label
                    htmlFor="message"
                    className={cn(
                      "absolute left-4 transition-all duration-300 pointer-events-none",
                      focused === "message" || formState.message
                        ? "-top-2.5 text-xs text-primary bg-surface/50 px-1"
                        : "top-3.5 text-sm text-muted"
                    )}
                  >
                    Your Message
                  </label>
                  <textarea
                    id="message"
                    required
                    rows={5}
                    value={formState.message}
                    onChange={(e) =>
                      setFormState({ ...formState, message: e.target.value })
                    }
                    onFocus={() => setFocused("message")}
                    onBlur={() => setFocused(null)}
                    className="w-full resize-none rounded-xl border border-white/10 bg-background/50 px-4 py-3.5 text-sm text-foreground transition-all duration-300 hover:border-white/20 focus:border-primary/50"
                  />
                </div>

                {/* Submit */}
                <button
                  type="submit"
                  onClick={handleRipple}
                  className="group relative w-full overflow-hidden rounded-xl bg-gradient-to-r from-primary to-accent py-3.5 text-sm font-medium text-white transition-shadow hover:shadow-[0_0_30px_rgba(0,200,150,0.3)]"
                >
                  <span className="relative z-10 flex items-center justify-center gap-2">
                    Send Message
                    <Send className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                  </span>
                </button>
              </form>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
