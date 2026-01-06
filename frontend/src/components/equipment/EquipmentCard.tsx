import Link from "next/link";
import type { Equipment } from "@/types";

interface EquipmentCardProps {
  equipment: Equipment;
}

export function EquipmentCard({ equipment }: EquipmentCardProps) {
  const mainImage = equipment.images?.find((img) => img.type === "main");

  return (
    <Link
      href={`/equipment/${equipment.slug}`}
      className="block border rounded-lg overflow-hidden hover:shadow-lg transition"
    >
      <div className="aspect-square bg-gray-100 dark:bg-gray-800 flex items-center justify-center">
        {mainImage ? (
          <img
            src={mainImage.url}
            alt={equipment.model}
            className="object-cover w-full h-full"
          />
        ) : (
          <div className="text-4xl text-gray-400">🔊</div>
        )}
      </div>
      <div className="p-4">
        <p className="text-sm text-gray-500 dark:text-gray-400">
          {equipment.brand?.name}
        </p>
        <h3 className="font-semibold text-lg">{equipment.model}</h3>
        {equipment.msrpJpy && (
          <p className="text-blue-600 font-medium mt-2">
            ¥{equipment.msrpJpy.toLocaleString()}
          </p>
        )}
        {equipment.lowestPrice && (
          <p className="text-green-600 text-sm">
            最安 ¥{equipment.lowestPrice.priceJpy.toLocaleString()}
          </p>
        )}
      </div>
    </Link>
  );
}
