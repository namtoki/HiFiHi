"use client";

import { useEquipmentList, useCategories } from "@/hooks/useEquipment";
import { EquipmentList } from "@/components/equipment/EquipmentList";

export default function AmplifiersPage() {
  const { data: categories } = useCategories();
  const ampCategory = categories?.find((c) => c.name === "amplifier");

  const { data, isLoading } = useEquipmentList(
    ampCategory ? { categoryId: ampCategory.id } : undefined
  );

  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">アンプ</h1>
      <p className="text-gray-600 dark:text-gray-400 mb-8">
        プリメインアンプ、パワーアンプ、真空管アンプなど
      </p>
      <EquipmentList
        equipment={data?.data || []}
        loading={isLoading || !ampCategory}
      />
    </div>
  );
}
