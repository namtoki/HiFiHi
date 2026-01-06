interface CompatibilityScoreProps {
  score: number;
  size?: "sm" | "md" | "lg";
}

export function CompatibilityScore({
  score,
  size = "md",
}: CompatibilityScoreProps) {
  const getColor = (score: number) => {
    if (score >= 4) return "bg-green-500";
    if (score >= 3) return "bg-yellow-500";
    if (score >= 2) return "bg-orange-500";
    return "bg-red-500";
  };

  const getLabel = (score: number) => {
    if (score >= 5) return "最適";
    if (score >= 4) return "良好";
    if (score >= 3) return "普通";
    if (score >= 2) return "注意";
    return "非推奨";
  };

  const sizeClasses = {
    sm: "w-8 h-8 text-sm",
    md: "w-12 h-12 text-lg",
    lg: "w-16 h-16 text-2xl",
  };

  return (
    <div className="flex items-center gap-2">
      <div
        className={`${sizeClasses[size]} ${getColor(score)} rounded-full flex items-center justify-center text-white font-bold`}
      >
        {score}
      </div>
      <span className="text-sm text-gray-600 dark:text-gray-400">
        {getLabel(score)}
      </span>
    </div>
  );
}
