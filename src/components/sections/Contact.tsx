"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { Send, CheckCircle, ArrowUpRight } from "lucide-react";
import MagneticButton from "@/components/ui/MagneticButton";
import GradientMesh from "@/components/ui/GradientMesh";
import { useSlide } from "@/context/SlideContext";
import { useLanguage } from "@/context/LanguageContext";

export default function Contact() {
  const { goToSlide } = useSlide();
  const { t, isRTL } = useLanguage();
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [isSending, setIsSending] = useState(false);
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    message: "",
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSending(true);
    await new Promise((resolve) => setTimeout(resolve, 1500));
    setIsSending(false);
    setIsSubmitted(true);
  };

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    setFormData((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const footerCompanyLinks = [
    { label: t.footer.company.about, slideIndex: 3 },
    { label: t.footer.company.services, slideIndex: 4 },
    { label: t.footer.company.projects, slideIndex: 2 },
  ];

  const footerConnectLinks = [
    { label: t.footer.connect.linkedin, href: "#" },
    { label: t.footer.connect.twitter, href: "#" },
    { label: t.footer.connect.github, href: "#" },
  ];

  return (
    <section id="contact" className="relative h-screen flex flex-col justify-center overflow-hidden">
      <GradientMesh className="opacity-40" />

      {/* Accent glow */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[600px] h-[600px] rounded-full bg-brand-green/[0.03] blur-[80px]" />

      <div className="max-w-5xl mx-auto px-6 relative z-10 w-full">
        <div className={`grid grid-cols-1 lg:grid-cols-2 gap-10 items-start ${isRTL ? "direction-rtl" : ""}`}>
          {/* Left — CTA Copy */}
          <motion.div
            initial={{ opacity: 0, x: isRTL ? 40 : -40, filter: "blur(8px)" }}
            animate={{ opacity: 1, x: 0, filter: "blur(0px)" }}
            transition={{ duration: 0.8, ease: [0.19, 1, 0.22, 1] }}
            className={isRTL ? "text-right" : ""}
          >
            <span className="text-small font-mono text-brand-green uppercase tracking-widest mb-4 block">
              &mdash; {t.contact.label}
            </span>
            <h2 className="text-display mb-4" style={{ color: "var(--text-primary)" }}>
              {t.contact.heading}{" "}
              <span className="text-gradient">{t.contact.headingAccent}</span>
            </h2>
            <p className="text-body-lg mb-8 leading-relaxed" style={{ color: "var(--text-secondary)" }}>
              {t.contact.description}
            </p>

            <div className="space-y-4">
              {t.contact.features.map((item, i) => (
                <motion.div
                  key={item}
                  initial={{ opacity: 0, x: isRTL ? 20 : -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.3 + i * 0.1, duration: 0.5 }}
                  className={`flex items-center gap-3 group ${isRTL ? "flex-row-reverse" : ""}`}
                >
                  <div className="w-8 h-[1px] bg-gradient-accent group-hover:w-12 transition-all duration-300" />
                  <span className="text-body" style={{ color: "var(--text-muted-light)" }}>{item}</span>
                </motion.div>
              ))}
            </div>
          </motion.div>

          {/* Right — Form */}
          <motion.div
            initial={{ opacity: 0, x: isRTL ? -40 : 40, filter: "blur(8px)" }}
            animate={{ opacity: 1, x: 0, filter: "blur(0px)" }}
            transition={{
              duration: 0.8,
              delay: 0.2,
              ease: [0.19, 1, 0.22, 1],
            }}
          >
            <div className="glass rounded-3xl p-6 md:p-8 glow-border relative overflow-hidden">
              {/* Subtle top accent */}
              <div
                className="absolute top-0 left-0 right-0 h-[1px]"
                style={{
                  background: "linear-gradient(90deg, transparent, rgba(0, 200, 150, 0.3), transparent)",
                }}
              />

              {isSubmitted ? (
                <motion.div
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ duration: 0.5 }}
                  className="text-center py-12"
                >
                  <motion.div
                    initial={{ scale: 0, rotate: -180 }}
                    animate={{ scale: 1, rotate: 0 }}
                    transition={{
                      type: "spring",
                      stiffness: 200,
                      damping: 15,
                      delay: 0.2,
                    }}
                    className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-brand-green/10 mb-4 relative"
                  >
                    <div className="absolute inset-0 rounded-full bg-brand-green/5 animate-ping" />
                    <CheckCircle size={30} className="text-brand-green" />
                  </motion.div>
                  <h3 className="text-heading mb-2" style={{ color: "var(--text-primary)" }}>
                    {t.contact.form.successTitle}
                  </h3>
                  <p className="text-body" style={{ color: "var(--text-secondary)" }}>
                    {t.contact.form.successMessage}
                  </p>
                </motion.div>
              ) : (
                <form onSubmit={handleSubmit} className={`space-y-4 ${isRTL ? "text-right" : ""}`} dir={isRTL ? "rtl" : "ltr"}>
                  {/* Name & Email row */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div className="group">
                      <label
                        htmlFor="name"
                        className="block text-xs font-medium mb-1.5 group-focus-within:text-brand-green transition-colors duration-300"
                        style={{ color: "var(--text-muted-light)" }}
                      >
                        {t.contact.form.name}
                      </label>
                      <input
                        type="text"
                        id="name"
                        name="name"
                        required
                        value={formData.name}
                        onChange={handleChange}
                        placeholder={t.contact.form.namePlaceholder}
                        className="w-full px-4 py-3 rounded-xl text-sm focus:outline-none focus:border-brand-green/40 focus:ring-2 focus:ring-brand-green/10 transition-all duration-300"
                        style={{
                          backgroundColor: "var(--input-bg)",
                          border: "1px solid var(--input-border)",
                          color: "var(--text-primary)",
                        }}
                      />
                    </div>
                    <div className="group">
                      <label
                        htmlFor="email"
                        className="block text-xs font-medium mb-1.5 group-focus-within:text-brand-green transition-colors duration-300"
                        style={{ color: "var(--text-muted-light)" }}
                      >
                        {t.contact.form.email}
                      </label>
                      <input
                        type="email"
                        id="email"
                        name="email"
                        required
                        value={formData.email}
                        onChange={handleChange}
                        placeholder={t.contact.form.emailPlaceholder}
                        className="w-full px-4 py-3 rounded-xl text-sm focus:outline-none focus:border-brand-green/40 focus:ring-2 focus:ring-brand-green/10 transition-all duration-300"
                        style={{
                          backgroundColor: "var(--input-bg)",
                          border: "1px solid var(--input-border)",
                          color: "var(--text-primary)",
                        }}
                      />
                    </div>
                  </div>

                  {/* Message */}
                  <div className="group">
                    <label
                      htmlFor="message"
                      className="block text-xs font-medium mb-1.5 group-focus-within:text-brand-green transition-colors duration-300"
                      style={{ color: "var(--text-muted-light)" }}
                    >
                      {t.contact.form.message}
                    </label>
                    <textarea
                      id="message"
                      name="message"
                      required
                      rows={3}
                      value={formData.message}
                      onChange={handleChange}
                      placeholder={t.contact.form.messagePlaceholder}
                      className="w-full px-4 py-3 rounded-xl text-sm focus:outline-none focus:border-brand-green/40 focus:ring-2 focus:ring-brand-green/10 transition-all duration-300 resize-none"
                      style={{
                        backgroundColor: "var(--input-bg)",
                        border: "1px solid var(--input-border)",
                        color: "var(--text-primary)",
                      }}
                    />
                  </div>

                  {/* Submit */}
                  <MagneticButton
                    className="w-full py-3.5 rounded-xl bg-gradient-accent text-white font-medium text-sm flex items-center justify-center gap-2.5 hover:shadow-glow-lg transition-all duration-500 disabled:opacity-50 relative overflow-hidden"
                    strength={0.15}
                  >
                    <motion.div
                      className="absolute inset-0"
                      animate={{ translateX: ["-100%", "200%"] }}
                      transition={{ duration: 3, repeat: Infinity, repeatDelay: 3, ease: "easeInOut" }}
                      style={{
                        background: "linear-gradient(90deg, transparent, rgba(255,255,255,0.08), transparent)",
                      }}
                    />
                    <span className="relative z-10 flex items-center gap-2.5">
                      {isSending ? (
                        <motion.div
                          animate={{ rotate: 360 }}
                          transition={{
                            duration: 1,
                            repeat: Infinity,
                            ease: "linear",
                          }}
                          className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full"
                        />
                      ) : (
                        <>
                          {t.contact.form.send}
                          <Send size={14} />
                        </>
                      )}
                    </span>
                  </MagneticButton>
                </form>
              )}
            </div>
          </motion.div>
        </div>

        {/* Footer section merged */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6, duration: 0.8 }}
          className="mt-10 pt-8"
          style={{ borderTop: "1px solid var(--border-color)" }}
        >
          <div className={`flex flex-col md:flex-row items-start md:items-center justify-between gap-6 ${isRTL ? "md:flex-row-reverse" : ""}`}>
            {/* Brand */}
            <div className={`flex items-center gap-6 ${isRTL ? "flex-row-reverse" : ""}`}>
              <button
                onClick={() => goToSlide(0)}
                className="flex items-center gap-2 group"
                data-cursor-hover
              >
                <div className="w-8 h-8 rounded-lg bg-gradient-accent flex items-center justify-center font-bold text-xs text-white">
                  In
                </div>
                <span
                  className="text-base font-semibold tracking-tight group-hover:text-brand-green transition-colors duration-300"
                  style={{ color: "var(--text-primary)" }}
                >
                  InST
                </span>
              </button>
              <span className="text-xs hidden sm:block" style={{ color: "var(--text-muted)" }}>
                &copy; {new Date().getFullYear()} {t.footer.copyright}
              </span>
            </div>

            {/* Quick Links */}
            <div className={`flex items-center gap-6 ${isRTL ? "flex-row-reverse" : ""}`}>
              {footerCompanyLinks.map((link) => (
                <button
                  key={link.label}
                  onClick={() => goToSlide(link.slideIndex)}
                  data-cursor-hover
                  className="text-xs transition-colors duration-300"
                  style={{ color: "var(--text-secondary)" }}
                >
                  {link.label}
                </button>
              ))}
              <span className="w-px h-3" style={{ backgroundColor: "var(--border-color)" }} />
              {footerConnectLinks.map((link) => (
                <a
                  key={link.label}
                  href={link.href}
                  data-cursor-hover
                  className="text-xs transition-colors duration-300 flex items-center gap-1 group"
                  style={{ color: "var(--text-secondary)" }}
                >
                  {link.label}
                  <ArrowUpRight
                    size={10}
                    className="opacity-0 group-hover:opacity-100 transition-opacity duration-300"
                  />
                </a>
              ))}
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
