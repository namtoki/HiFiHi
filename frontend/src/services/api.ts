import type {
  Equipment,
  Category,
  Brand,
  Compatibility,
  PaginatedResponse,
  EquipmentFilters,
} from "@/types";

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3001/api";

async function fetchApi<T>(endpoint: string, options?: RequestInit): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    headers: {
      "Content-Type": "application/json",
      ...options?.headers,
    },
    ...options,
  });

  if (!response.ok) {
    throw new Error(`API error: ${response.status}`);
  }

  return response.json();
}

export const api = {
  categories: {
    list: () => fetchApi<Category[]>("/categories"),
    get: (id: string) => fetchApi<Category>(`/categories/${id}`),
  },

  brands: {
    list: () => fetchApi<Brand[]>("/brands"),
    get: (slug: string) => fetchApi<Brand>(`/brands/${slug}`),
  },

  equipment: {
    list: (filters?: EquipmentFilters & { page?: number; limit?: number }) => {
      const params = new URLSearchParams();
      if (filters) {
        Object.entries(filters).forEach(([key, value]) => {
          if (value !== undefined) {
            params.append(key, String(value));
          }
        });
      }
      const query = params.toString();
      return fetchApi<PaginatedResponse<Equipment>>(
        `/equipment${query ? `?${query}` : ""}`
      );
    },
    get: (slug: string) => fetchApi<Equipment>(`/equipment/${slug}`),
    getCompatibility: (slug: string) =>
      fetchApi<Compatibility[]>(`/equipment/${slug}/compatibility`),
  },

  search: {
    query: (q: string) => fetchApi<Equipment[]>(`/search?q=${encodeURIComponent(q)}`),
  },
};
