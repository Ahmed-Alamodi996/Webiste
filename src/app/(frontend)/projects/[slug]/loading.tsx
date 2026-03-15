export default function ProjectLoading() {
  return (
    <div
      style={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        backgroundColor: "var(--bg-primary, #0B0F19)",
      }}
    >
      <div style={{ textAlign: "center" }}>
        <div
          style={{
            width: "2.5rem",
            height: "2.5rem",
            border: "2px solid rgba(0, 200, 150, 0.2)",
            borderTopColor: "#00C896",
            borderRadius: "50%",
            animation: "spin 0.8s linear infinite",
            margin: "0 auto 1rem",
          }}
        />
        <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
      </div>
    </div>
  );
}
