"use client";

import { useEquipmentList, useCategories } from "@/hooks/useEquipment";
import { EquipmentList } from "@/components/equipment/EquipmentList";

export default function SpeakersPage() {
  const { data: categories } = useCategories();
  const speakerCategory = categories?.find((c) => c.name === "speaker");

  const { data, isLoading } = useEquipmentList(
    speakerCategory ? { categoryId: speakerCategory.id } : undefined
  );

  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">スピーカー</h1>
      <p className="text-gray-600 dark:text-gray-400 mb-8">
        フロアスタンディング、ブックシェルフ、サブウーファーなど
      </p>
      <EquipmentList
        equipment={data?.data || []}
        loading={isLoading || !speakerCategory}
      />
    </div>
  );
}
