"use client";

import { use } from "react";
import Link from "next/link";
import { useEquipment, useEquipmentCompatibility } from "@/hooks/useEquipment";
import { CompatibilityScore } from "@/components/compatibility/CompatibilityScore";

interface Props {
  params: Promise<{ slug: string }>;
}

export default function EquipmentDetailPage({ params }: Props) {
  const { slug } = use(params);
  const { data: equipment, isLoading, error } = useEquipment(slug);
  const { data: compatibility } = useEquipmentCompatibility(slug);

  if (isLoading) {
    return (
      <div className="animate-pulse">
        <div className="h-8 bg-gray-200 dark:bg-gray-700 rounded w-1/3 mb-4" />
        <div className="h-6 bg-gray-200 dark:bg-gray-700 rounded w-1/4 mb-8" />
        <div className="grid md:grid-cols-2 gap-8">
          <div className="aspect-square bg-gray-200 dark:bg-gray-700 rounded" />
          <div className="space-y-4">
            <div className="h-6 bg-gray-200 dark:bg-gray-700 rounded w-1/2" />
            <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-3/4" />
            <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-2/3" />
          </div>
        </div>
      </div>
    );
  }

  if (error || !equipment) {
    return (
      <div className="text-center py-12">
        <h1 className="text-2xl font-bold mb-4">機器が見つかりません</h1>
        <Link href="/" className="text-blue-600 hover:underline">
          トップに戻る
        </Link>
      </div>
    );
  }

  const mainImage = equipment.images?.find((img) => img.type === "main");
  const specs = equipment.specs as Record<string, unknown>;

  return (
    <div>
      <nav className="text-sm mb-4 text-gray-500">
        <Link href="/" className="hover:text-blue-600">
          ホーム
        </Link>
        {" / "}
        <Link
          href={`/${equipment.category?.name}s`}
          className="hover:text-blue-600"
        >
          {equipment.category?.displayName}
        </Link>
        {" / "}
        <span>{equipment.model}</span>
      </nav>

      <div className="grid md:grid-cols-2 gap-8 mb-12">
        <div className="aspect-square bg-gray-100 dark:bg-gray-800 rounded-lg flex items-center justify-center">
          {mainImage ? (
            <img
              src={mainImage.url}
              alt={equipment.model}
              className="object-contain w-full h-full"
            />
          ) : (
            <div className="text-6xl text-gray-400">🔊</div>
          )}
        </div>

        <div>
          <p className="text-gray-500 dark:text-gray-400 mb-1">
            {equipment.brand?.name}
          </p>
          <h1 className="text-3xl font-bold mb-4">{equipment.model}</h1>

          {equipment.msrpJpy && (
            <p className="text-2xl text-blue-600 font-bold mb-4">
              ¥{equipment.msrpJpy.toLocaleString()}
              <span className="text-sm font-normal text-gray-500 ml-2">
                (税込定価)
              </span>
            </p>
          )}

          {equipment.releaseYear && (
            <p className="text-gray-500 mb-4">
              発売年: {equipment.releaseYear}年
            </p>
          )}

          {equipment.description && (
            <p className="text-gray-600 dark:text-gray-400 mb-6">
              {equipment.description}
            </p>
          )}

          {equipment.features && equipment.features.length > 0 && (
            <div className="mb-6">
              <h3 className="font-semibold mb-2">特徴</h3>
              <ul className="flex flex-wrap gap-2">
                {equipment.features.map((feature, i) => (
                  <li
                    key={i}
                    className="bg-gray-100 dark:bg-gray-800 px-3 py-1 rounded-full text-sm"
                  >
                    {feature}
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      </div>

      <section className="mb-12">
        <h2 className="text-2xl font-bold mb-4">スペック</h2>
        <div className="bg-gray-50 dark:bg-gray-800 rounded-lg p-6">
          <dl className="grid grid-cols-2 md:grid-cols-3 gap-4">
            {specs.type && (
              <>
                <dt className="text-gray-500">タイプ</dt>
                <dd className="col-span-1 md:col-span-2">{String(specs.type)}</dd>
              </>
            )}
            {specs.impedanceOhm && (
              <>
                <dt className="text-gray-500">インピーダンス</dt>
                <dd className="col-span-1 md:col-span-2">
                  {String(specs.impedanceOhm)}Ω
                </dd>
              </>
            )}
            {specs.sensitivityDb && (
              <>
                <dt className="text-gray-500">感度</dt>
                <dd className="col-span-1 md:col-span-2">
                  {String(specs.sensitivityDb)}dB
                </dd>
              </>
            )}
            {specs.frequencyHz && Array.isArray(specs.frequencyHz) && (
              <>
                <dt className="text-gray-500">周波数特性</dt>
                <dd className="col-span-1 md:col-span-2">
                  {specs.frequencyHz[0]}Hz - {specs.frequencyHz[1]}Hz
                </dd>
              </>
            )}
            {specs.powerWMin && specs.powerWMax && (
              <>
                <dt className="text-gray-500">推奨入力</dt>
                <dd className="col-span-1 md:col-span-2">
                  {String(specs.powerWMin)}W - {String(specs.powerWMax)}W
                </dd>
              </>
            )}
            {specs.outputW8ohm && (
              <>
                <dt className="text-gray-500">出力 (8Ω)</dt>
                <dd className="col-span-1 md:col-span-2">
                  {String(specs.outputW8ohm)}W
                </dd>
              </>
            )}
            {specs.outputW4ohm && (
              <>
                <dt className="text-gray-500">出力 (4Ω)</dt>
                <dd className="col-span-1 md:col-span-2">
                  {String(specs.outputW4ohm)}W
                </dd>
              </>
            )}
            {specs.bitDepth && (
              <>
                <dt className="text-gray-500">ビット深度</dt>
                <dd className="col-span-1 md:col-span-2">
                  {String(specs.bitDepth)}bit
                </dd>
              </>
            )}
            {specs.sampleRateKhz && (
              <>
                <dt className="text-gray-500">サンプリングレート</dt>
                <dd className="col-span-1 md:col-span-2">
                  {String(specs.sampleRateKhz)}kHz
                </dd>
              </>
            )}
          </dl>
        </div>
      </section>

      {compatibility && compatibility.length > 0 && (
        <section>
          <h2 className="text-2xl font-bold mb-4">互換性のある機器</h2>
          <div className="space-y-4">
            {compatibility.map((comp) => (
              <Link
                key={comp.id}
                href={`/equipment/${comp.otherEquipment?.slug}`}
                className="block border rounded-lg p-4 hover:shadow-md transition"
              >
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-gray-500">
                      {comp.otherEquipment?.brandName} /{" "}
                      {comp.otherEquipment?.categoryName}
                    </p>
                    <p className="font-semibold">
                      {comp.otherEquipment?.model}
                    </p>
                  </div>
                  <CompatibilityScore score={comp.compatibilityScore} />
                </div>
                {comp.compatibilityDetails?.notes && (
                  <p className="text-sm text-gray-600 dark:text-gray-400 mt-2">
                    {String(comp.compatibilityDetails.notes)}
                  </p>
                )}
              </Link>
            ))}
          </div>
        </section>
      )}
    </div>
  );
}
