"use client";

import { useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import { useSearch } from "@/hooks/useEquipment";

export function SearchBar() {
  const [query, setQuery] = useState("");
  const [isOpen, setIsOpen] = useState(false);
  const router = useRouter();
  const { data: results, isLoading } = useSearch(query);

  const handleSubmit = useCallback(
    (e: React.FormEvent) => {
      e.preventDefault();
      if (query.trim()) {
        router.push(`/search?q=${encodeURIComponent(query)}`);
        setIsOpen(false);
      }
    },
    [query, router]
  );

  return (
    <div className="relative">
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          value={query}
          onChange={(e) => {
            setQuery(e.target.value);
            setIsOpen(true);
          }}
          onFocus={() => setIsOpen(true)}
          placeholder="機器を検索..."
          className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </form>

      {isOpen && query.length >= 2 && (
        <div className="absolute top-full left-0 right-0 mt-1 bg-white dark:bg-gray-800 border rounded-lg shadow-lg z-50 max-h-96 overflow-auto">
          {isLoading ? (
            <div className="p-4 text-center text-gray-500">検索中...</div>
          ) : results && results.length > 0 ? (
            <ul>
              {results.map((item) => (
                <li key={item.id}>
                  <button
                    onClick={() => {
                      router.push(`/equipment/${item.slug}`);
                      setIsOpen(false);
                      setQuery("");
                    }}
                    className="w-full px-4 py-2 text-left hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center gap-3"
                  >
                    <span className="text-sm text-gray-500">
                      {item.brand?.name}
                    </span>
                    <span className="font-medium">{item.model}</span>
                  </button>
                </li>
              ))}
            </ul>
          ) : (
            <div className="p-4 text-center text-gray-500">
              結果が見つかりません
            </div>
          )}
        </div>
      )}
    </div>
  );
}
