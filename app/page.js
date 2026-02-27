import styles from "./page.module.css";

export default function Home() {
  return (
    <main className={styles.main}>
      <h1 className={styles.title}>BrightPath</h1>
      <p className={styles.subtitle}>Welcome to your Docker-powered Next.js app.</p>
      <div className={styles.card}>
        <h2>Docker Lab Running ✅</h2>
        <p>
          If you can see this page at <strong>http://localhost:3000</strong>,
          your containerized app is up and running.
        </p>
      </div>
    </main>
  );
}
