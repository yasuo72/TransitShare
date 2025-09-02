// Basic geo helpers (Haversine formula & distance along route)
export const haversine = (lat1, lon1, lat2, lon2) => {
  const toRad = deg => (deg * Math.PI) / 180;
  const R = 6371e3; // metres
  const φ1 = toRad(lat1);
  const φ2 = toRad(lat2);
  const Δφ = toRad(lat2 - lat1);
  const Δλ = toRad(lon2 - lon1);
  const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
    Math.cos(φ1) * Math.cos(φ2) *
    Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c; // metres
};

// distance remaining along polyline from current to end
export const distanceRemaining = (path, currentIdx = 0) => {
  let dist = 0;
  for (let i = currentIdx; i < path.length - 1; i++) {
    const a = path[i];
    const b = path[i + 1];
    dist += haversine(a.lat, a.lng, b.lat, b.lng);
  }
  return dist; // metres
};
