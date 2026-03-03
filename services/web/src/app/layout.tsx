import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import Link from 'next/link';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'OpenClaw | Book-First Learning',
  description:
    'Education and playbook guidance for SPY options traders. Book-first learning environment.',
};

/**
 * Navigation items aligned to canonical page set.
 * Shell-level only — no product logic.
 */
const navItems = [
  { href: '/', label: 'Library' },
  { href: '/book', label: 'Reader' },
  { href: '/notes', label: 'Notes' },
  { href: '/playbooks', label: 'Playbooks' },
  { href: '/admin', label: 'Admin' },
];

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${inter.className} antialiased`}>
        {/* Top navigation bar — minimal chrome per design system (04-TECHP) */}
        <header className="border-b border-neutral-200 bg-white dark:border-neutral-800 dark:bg-neutral-950">
          <nav className="mx-auto flex max-w-7xl items-center gap-6 px-4 py-3">
            <Link
              href="/"
              className="text-base font-semibold tracking-tight text-neutral-900 dark:text-neutral-100"
            >
              OpenClaw
            </Link>
            <div className="flex gap-4">
              {navItems.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className="text-sm text-neutral-600 transition-colors hover:text-neutral-900 dark:text-neutral-400 dark:hover:text-neutral-100"
                >
                  {item.label}
                </Link>
              ))}
            </div>
            <div className="ml-auto">
              <Link
                href="/login"
                className="text-sm text-neutral-500 hover:text-neutral-800 dark:text-neutral-400 dark:hover:text-neutral-200"
              >
                Sign in
              </Link>
            </div>
          </nav>
        </header>

        <main className="mx-auto max-w-7xl">{children}</main>
      </body>
    </html>
  );
}
