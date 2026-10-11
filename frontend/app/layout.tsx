import './globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'PRE-ICFES',
  description: 'Sistema de gestión académica y administrativa',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body>{children}</body>
    </html>
  );
}
