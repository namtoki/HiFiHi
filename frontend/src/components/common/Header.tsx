import Link from "next/link";

export function Header() {
  return (
    <header className="border-b">
      <div className="container mx-auto px-4 py-4 flex items-center justify-between">
        <Link href="/" className="text-xl font-bold">
          HiFi Audio
        </Link>
        <nav className="flex items-center gap-6">
          <Link
            href="/speakers"
            className="hover:text-blue-600 transition"
          >
            スピーカー
          </Link>
          <Link
            href="/amplifiers"
            className="hover:text-blue-600 transition"
          >
            アンプ
          </Link>
          <Link
            href="/dacs"
            className="hover:text-blue-600 transition"
          >
            DAC
          </Link>
          <Link
            href="/combinations"
            className="hover:text-blue-600 transition"
          >
            組み合わせ
          </Link>
        </nav>
      </div>
    </header>
  );
}
