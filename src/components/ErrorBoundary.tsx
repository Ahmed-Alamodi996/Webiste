"use client";

import { Component, type ReactNode } from "react";

interface ErrorBoundaryProps {
  children: ReactNode;
  fallback?: ReactNode;
}

interface ErrorBoundaryState {
  hasError: boolean;
}

export default class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(): ErrorBoundaryState {
    return { hasError: true };
  }

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback || (
          <div className="min-h-screen flex items-center justify-center" style={{ backgroundColor: "var(--bg-primary)" }}>
            <div className="text-center px-6 max-w-md">
              <div className="w-16 h-16 rounded-2xl bg-gradient-accent flex items-center justify-center mx-auto mb-6">
                <span className="text-white font-bold text-xl">!</span>
              </div>
              <h2
                className="text-2xl font-semibold mb-3"
                style={{ color: "var(--text-primary)" }}
              >
                Something went wrong
              </h2>
              <p className="text-sm mb-6" style={{ color: "var(--text-secondary)" }}>
                An unexpected error occurred. Please try refreshing the page.
              </p>
              <button
                onClick={() => {
                  this.setState({ hasError: false });
                  window.location.reload();
                }}
                className="px-6 py-3 rounded-full bg-gradient-accent text-white text-sm font-medium hover:shadow-glow-lg transition-all duration-300"
              >
                Refresh Page
              </button>
            </div>
          </div>
        )
      );
    }

    return this.props.children;
  }
}
