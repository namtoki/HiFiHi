export interface Category {
  id: string;
  name: string;
  displayName: string;
  parentId: string | null;
  sortOrder: number;
}

export interface Brand {
  id: string;
  name: string;
  slug: string;
  country: string | null;
  websiteUrl: string | null;
  logoUrl: string | null;
  description: string | null;
}

export interface Equipment {
  id: string;
  categoryId: string;
  brandId: string;
  model: string;
  slug: string;
  releaseYear: number | null;
  msrpJpy: number | null;
  status: "active" | "discontinued" | "upcoming";
  specs: Record<string, unknown>;
  images: EquipmentImage[];
  description: string | null;
  features: string[];
  brand?: Brand;
  category?: Category;
  lowestPrice?: LowestPrice;
  averageRating?: number;
  reviewCount?: number;
}

export interface EquipmentImage {
  url: string;
  type: "main" | "side" | "back" | "detail";
}

export interface LowestPrice {
  priceJpy: number;
  shop: {
    name: string;
    slug: string;
  };
  stockStatus: "in_stock" | "limited" | "out_of_stock" | "preorder";
  fetchedAt: string;
}

export interface SpeakerSpecs {
  type: "floorstanding" | "bookshelf" | "subwoofer" | "center";
  impedanceOhm: number;
  sensitivityDb: number;
  frequencyHz: [number, number];
  powerWMin: number;
  powerWMax: number;
  drivers?: {
    tweeter?: string;
    woofer?: string;
    midrange?: string;
  };
  dimensions?: {
    heightMm: number;
    widthMm: number;
    depthMm: number;
  };
  weightKg?: number;
}

export interface AmplifierSpecs {
  type: "integrated" | "power" | "tube" | "headphone";
  outputW8ohm: number;
  outputW4ohm?: number;
  thdPercent?: number;
  inputTypes: string[];
  outputTypes?: string[];
}

export interface DacSpecs {
  bitDepth: number;
  sampleRateKhz: number;
  dsdSupport: boolean;
  inputs: string[];
  outputs: string[];
}

export interface Compatibility {
  id: string;
  equipmentAId: string;
  equipmentBId: string;
  compatibilityScore: number;
  compatibilityDetails: {
    powerMatch?: "excellent" | "good" | "fair" | "poor";
    impedanceMatch?: "excellent" | "good" | "fair" | "poor";
    notes?: string;
  };
  source: "official" | "user" | "article" | "calculated";
  sourceUrl?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface EquipmentFilters {
  categoryId?: string;
  brandId?: string;
  status?: string;
  minPrice?: number;
  maxPrice?: number;
  search?: string;
}
