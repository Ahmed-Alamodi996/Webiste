"use client";

import { motion } from "framer-motion";
import { fadeInUp, staggerContainer, staggerItem } from "@/lib/animations";
import { ArrowUpRight } from "lucide-react";

const footerLinks = {
  Company: ["About", "Careers", "Blog", "Press"],
  Solutions: ["AI & ML", "Cloud Infrastructure", "Web Platforms", "Mobile Apps"],
  Resources: ["Documentation", "Case Studies", "Support", "API"],
  Legal: ["Privacy Policy", "Terms of Service", "Cookie Policy"],
};

export default function Footer() {
  return (
    <footer className="relative border-t border-white/5 bg-background">
      <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.2 }}
          className="grid gap-12 md:grid-cols-2 lg:grid-cols-6"
        >
          {/* Brand */}
          <motion.div variants={staggerItem} className="lg:col-span-2">
            <div className="flex items-center gap-2">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-gradient-to-br from-primary to-accent">
                <span className="text-sm font-bold text-white">In</span>
              </div>
              <span className="text-lg font-semibold">InST</span>
            </div>
            <p className="mt-4 max-w-xs text-sm leading-relaxed text-muted">
              Engineering the future of intelligent solutions. We build
              technology that transforms industries and empowers innovation.
            </p>
            <div className="mt-6 flex gap-4">
              {["X", "Li", "Gh"].map((social) => (
                <a
                  key={social}
                  href="#"
                  className="flex h-9 w-9 items-center justify-center rounded-lg border border-white/10 text-xs text-muted transition-all hover:border-primary/50 hover:text-primary"
                >
                  {social}
                </a>
              ))}
            </div>
          </motion.div>

          {/* Links */}
          {Object.entries(footerLinks).map(([category, links]) => (
            <motion.div key={category} variants={staggerItem}>
              <h4 className="mb-4 text-sm font-semibold text-foreground">
                {category}
              </h4>
              <ul className="space-y-3">
                {links.map((link) => (
                  <li key={link}>
                    <a
                      href="#"
                      className="group flex items-center gap-1 text-sm text-muted transition-colors hover:text-foreground"
                    >
                      {link}
                      <ArrowUpRight
                        size={12}
                        className="opacity-0 transition-all group-hover:opacity-100"
                      />
                    </a>
                  </li>
                ))}
              </ul>
            </motion.div>
          ))}
        </motion.div>

        {/* Bottom */}
        <motion.div
          variants={fadeInUp}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          className="mt-16 flex flex-col items-center justify-between gap-4 border-t border-white/5 pt-8 md:flex-row"
        >
          <p className="text-sm text-muted">
            &copy; {new Date().getFullYear()} Innovative Solutions Tech. All rights
            reserved.
          </p>
          <p className="text-xs text-muted/60">
            Designed & engineered with precision
          </p>
        </motion.div>
      </div>
    </footer>
  );
}
