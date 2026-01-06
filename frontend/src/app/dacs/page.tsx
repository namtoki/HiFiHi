"use client";

import { useEquipmentList, useCategories } from "@/hooks/useEquipment";
import { EquipmentList } from "@/components/equipment/EquipmentList";

export default function DacsPage() {
  const { data: categories } = useCategories();
  const dacCategory = categories?.find((c) => c.name === "dac");

  const { data, isLoading } = useEquipmentList(
    dacCategory ? { categoryId: dacCategory.id } : undefined
  );

  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">DAC</h1>
      <p className="text-gray-600 dark:text-gray-400 mb-8">
        USB DAC、ネットワークDAC、ポータブルDACなど
      </p>
      <EquipmentList
        equipment={data?.data || []}
        loading={isLoading || !dacCategory}
      />
    </div>
  );
}
