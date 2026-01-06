import Link from "next/link";

const categories = [
  {
    name: "スピーカー",
    slug: "speakers",
    description: "フロアスタンディング、ブックシェルフ、サブウーファー",
    icon: "🔊",
  },
  {
    name: "アンプ",
    slug: "amplifiers",
    description: "プリメインアンプ、パワーアンプ、真空管アンプ",
    icon: "🎛️",
  },
  {
    name: "DAC",
    slug: "dacs",
    description: "USB DAC、ネットワークDAC、ポータブルDAC",
    icon: "🎵",
  },
  {
    name: "ヘッドホン",
    slug: "headphones",
    description: "オープン型、クローズド型、イヤホン",
    icon: "🎧",
  },
];

export default function HomePage() {
  return (
    <div className="space-y-12">
      <section className="text-center py-12">
        <h1 className="text-4xl font-bold mb-4">HiFi Audio Platform</h1>
        <p className="text-xl text-gray-600 dark:text-gray-400 mb-8">
          オーディオ機器データベース＆価格比較プラットフォーム
        </p>
        <div className="flex justify-center gap-4">
          <Link
            href="/combinations"
            className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition"
          >
            組み合わせを探す
          </Link>
          <Link
            href="/equipment"
            className="border border-gray-300 px-6 py-3 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition"
          >
            機器一覧
          </Link>
        </div>
      </section>

      <section>
        <h2 className="text-2xl font-bold mb-6">カテゴリから探す</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {categories.map((category) => (
            <Link
              key={category.slug}
              href={`/${category.slug}`}
              className="block p-6 border rounded-lg hover:shadow-lg transition"
            >
              <div className="text-4xl mb-4">{category.icon}</div>
              <h3 className="text-xl font-semibold mb-2">{category.name}</h3>
              <p className="text-gray-600 dark:text-gray-400 text-sm">
                {category.description}
              </p>
            </Link>
          ))}
        </div>
      </section>
    </div>
  );
}
