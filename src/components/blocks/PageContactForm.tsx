"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { Send, CheckCircle } from "lucide-react";
import { useLanguage } from "@/context/LanguageContext";
import type { ContactFormBlockData } from "@/lib/cms-types";

export default function PageContactForm({
  block,
}: {
  block: ContactFormBlockData;
}) {
  const { t, isRTL } = useLanguage();
  const [formData, setFormData] = useState({ name: "", email: "", message: "" });
  const [isSending, setIsSending] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [submitError, setSubmitError] = useState("");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSending(true);
    setSubmitError("");
    try {
      const res = await fetch("/api/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });
      if (!res.ok) throw new Error("Failed to send");
      setIsSubmitted(true);
    } catch {
      setSubmitError("Something went wrong. Please try again.");
    } finally {
      setIsSending(false);
    }
  };

  const heading = block.heading || t.contact.heading;
  const headingAccent = block.headingAccent || t.contact.headingAccent;
  const description = block.description || t.contact.description;

  return (
    <section className="py-20 relative overflow-hidden">
      <div className="max-w-3xl mx-auto px-6">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.8, ease: [0.19, 1, 0.22, 1] }}
          className={`mb-10 ${isRTL ? "text-right" : ""}`}
        >
          <h2
            className="text-display mb-4"
            style={{ color: "var(--text-primary)" }}
          >
            {heading}{" "}
            <span className="text-gradient">{headingAccent}</span>
          </h2>
          <p
            className="text-body-lg max-w-xl"
            style={{ color: "var(--text-secondary)" }}
          >
            {description}
          </p>
        </motion.div>

        {/* Form */}
        {isSubmitted ? (
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="glass rounded-3xl p-10 text-center glow-border"
          >
            <CheckCircle
              size={48}
              className="mx-auto mb-4"
              style={{ color: "var(--brand-green)" }}
            />
            <h3
              className="text-xl font-bold mb-2"
              style={{ color: "var(--text-primary)" }}
            >
              {t.contact.form.successTitle}
            </h3>
            <p style={{ color: "var(--text-secondary)" }}>
              {t.contact.form.successMessage}
            </p>
          </motion.div>
        ) : (
          <motion.form
            onSubmit={handleSubmit}
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="glass rounded-3xl p-8 glow-border space-y-6"
          >
            <div>
              <label
                className="block text-sm font-medium mb-2"
                style={{ color: "var(--text-secondary)" }}
              >
                {t.contact.form.name}
              </label>
              <input
                type="text"
                required
                value={formData.name}
                onChange={(e) =>
                  setFormData({ ...formData, name: e.target.value })
                }
                placeholder={t.contact.form.namePlaceholder}
                className="w-full px-4 py-3 rounded-xl bg-transparent border transition-colors duration-300 outline-none"
                style={{
                  color: "var(--text-primary)",
                  borderColor: "var(--border-color)",
                }}
              />
            </div>

            <div>
              <label
                className="block text-sm font-medium mb-2"
                style={{ color: "var(--text-secondary)" }}
              >
                {t.contact.form.email}
              </label>
              <input
                type="email"
                required
                value={formData.email}
                onChange={(e) =>
                  setFormData({ ...formData, email: e.target.value })
                }
                placeholder={t.contact.form.emailPlaceholder}
                className="w-full px-4 py-3 rounded-xl bg-transparent border transition-colors duration-300 outline-none"
                style={{
                  color: "var(--text-primary)",
                  borderColor: "var(--border-color)",
                }}
              />
            </div>

            <div>
              <label
                className="block text-sm font-medium mb-2"
                style={{ color: "var(--text-secondary)" }}
              >
                {t.contact.form.message}
              </label>
              <textarea
                required
                rows={5}
                value={formData.message}
                onChange={(e) =>
                  setFormData({ ...formData, message: e.target.value })
                }
                placeholder={t.contact.form.messagePlaceholder}
                className="w-full px-4 py-3 rounded-xl bg-transparent border transition-colors duration-300 outline-none resize-none"
                style={{
                  color: "var(--text-primary)",
                  borderColor: "var(--border-color)",
                }}
              />
            </div>

            {submitError && (
              <p className="text-sm text-red-400">{submitError}</p>
            )}

            <button
              type="submit"
              disabled={isSending}
              data-cursor-hover
              className="w-full py-3 rounded-full bg-gradient-accent text-white font-medium text-sm flex items-center justify-center gap-2 hover:shadow-glow transition-all duration-300 disabled:opacity-50"
            >
              {isSending ? "..." : t.contact.form.send}
              {!isSending && <Send size={14} />}
            </button>
          </motion.form>
        )}
      </div>
    </section>
  );
}
