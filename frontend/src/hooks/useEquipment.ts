"use client";

import { useQuery } from "@tanstack/react-query";
import { api } from "@/services/api";
import type { EquipmentFilters } from "@/types";

export function useEquipmentList(
  filters?: EquipmentFilters & { page?: number; limit?: number }
) {
  return useQuery({
    queryKey: ["equipment", filters],
    queryFn: () => api.equipment.list(filters),
  });
}

export function useEquipment(slug: string) {
  return useQuery({
    queryKey: ["equipment", slug],
    queryFn: () => api.equipment.get(slug),
    enabled: !!slug,
  });
}

export function useEquipmentCompatibility(slug: string) {
  return useQuery({
    queryKey: ["equipment", slug, "compatibility"],
    queryFn: () => api.equipment.getCompatibility(slug),
    enabled: !!slug,
  });
}

export function useCategories() {
  return useQuery({
    queryKey: ["categories"],
    queryFn: () => api.categories.list(),
  });
}

export function useBrands() {
  return useQuery({
    queryKey: ["brands"],
    queryFn: () => api.brands.list(),
  });
}

export function useSearch(query: string) {
  return useQuery({
    queryKey: ["search", query],
    queryFn: () => api.search.query(query),
    enabled: query.length >= 2,
  });
}
