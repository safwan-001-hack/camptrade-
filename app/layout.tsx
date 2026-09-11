import "./globals.css";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "CampTrade — Your Campus. Your Market.",
  description: "A verified campus marketplace for students and campus businesses."
};

export default function RootLayout({children}:{children:React.ReactNode}) {
  return <html lang="en"><body>{children}</body></html>;
}