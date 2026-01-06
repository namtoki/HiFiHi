"use client";

import { useEquipmentList, useCategories } from "@/hooks/useEquipment";
import { EquipmentList } from "@/components/equipment/EquipmentList";

export default function HeadphonesPage() {
  const { data: categories } = useCategories();
  const hpCategory = categories?.find((c) => c.name === "headphone");

  const { data, isLoading } = useEquipmentList(
    hpCategory ? { categoryId: hpCategory.id } : undefined
  );

  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">ヘッドホン</h1>
      <p className="text-gray-600 dark:text-gray-400 mb-8">
        オープン型、クローズド型、イヤホンなど
      </p>
      <EquipmentList
        equipment={data?.data || []}
        loading={isLoading || !hpCategory}
      />
    </div>
  );
}
