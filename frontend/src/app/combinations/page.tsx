"use client";

import { useState } from "react";
import Link from "next/link";
import { useEquipmentList, useCategories } from "@/hooks/useEquipment";
import { CompatibilityScore } from "@/components/compatibility/CompatibilityScore";

export default function CombinationsPage() {
  const [selectedCategory, setSelectedCategory] = useState<string>("");
  const { data: categories } = useCategories();
  const { data: equipment } = useEquipmentList(
    selectedCategory ? { categoryId: selectedCategory } : undefined
  );

  return (
    <div>
      <h1 className="text-3xl font-bold mb-4">組み合わせ検索</h1>
      <p className="text-gray-600 dark:text-gray-400 mb-8">
        スピーカーとアンプ、DACとヘッドホンなど、機器の相性をチェックできます。
      </p>

      <div className="mb-8">
        <label className="block text-sm font-medium mb-2">
          カテゴリで絞り込み
        </label>
        <select
          value={selectedCategory}
          onChange={(e) => setSelectedCategory(e.target.value)}
          className="w-full md:w-64 px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <option value="">すべてのカテゴリ</option>
          {categories?.map((cat) => (
            <option key={cat.id} value={cat.id}>
              {cat.displayName}
            </option>
          ))}
        </select>
      </div>

      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        {equipment?.data.map((item) => (
          <Link
            key={item.id}
            href={`/equipment/${item.slug}`}
            className="block border rounded-lg p-4 hover:shadow-lg transition"
          >
            <p className="text-sm text-gray-500">{item.brand?.name}</p>
            <h3 className="font-semibold text-lg mb-2">{item.model}</h3>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-3">
              {item.category?.displayName}
            </p>
            <div className="text-sm text-blue-600">
              互換性情報を見る →
            </div>
          </Link>
        ))}
      </div>

      {!equipment?.data.length && (
        <div className="text-center py-12 text-gray-500">
          機器を選択してください
        </div>
      )}

      <section className="mt-12 bg-gray-50 dark:bg-gray-800 rounded-lg p-6">
        <h2 className="text-xl font-bold mb-4">互換性スコアについて</h2>
        <div className="space-y-3">
          <div className="flex items-center gap-4">
            <CompatibilityScore score={5} size="sm" />
            <span>最適な組み合わせ。問題なく使用可能。</span>
          </div>
          <div className="flex items-center gap-4">
            <CompatibilityScore score={4} size="sm" />
            <span>良好な組み合わせ。ほぼ問題なし。</span>
          </div>
          <div className="flex items-center gap-4">
            <CompatibilityScore score={3} size="sm" />
            <span>使用可能だが、一部制限あり。</span>
          </div>
          <div className="flex items-center gap-4">
            <CompatibilityScore score={2} size="sm" />
            <span>注意が必要。性能を発揮できない可能性。</span>
          </div>
          <div className="flex items-center gap-4">
            <CompatibilityScore score={1} size="sm" />
            <span>非推奨。機器を損傷する可能性。</span>
          </div>
        </div>
      </section>
    </div>
  );
}
