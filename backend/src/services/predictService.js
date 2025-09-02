import Route from "../models/Route.js";
import { distanceRemaining } from "../utils/geo.js";

/**
 * Simple ETA prediction based on last known location and average speed
 */
export const predictBusLocation = async (bus) => {
  if (!bus.lastKnownLocation || !bus.avgSpeed) return null;

  const route = await Route.findOne({ routeID: bus.routeID });
  if (!route) return null;

  // Find nearest point index on path
  const idx = route.pathCoordinates.findIndex(p =>
    Math.abs(p.lat - bus.lastKnownLocation.lat) < 0.001 &&
    Math.abs(p.lng - bus.lastKnownLocation.lng) < 0.001
  );
  const remaining = distanceRemaining(route.pathCoordinates, idx >= 0 ? idx : 0); // metres
  const speedMS = bus.avgSpeed || 10; // metres per sec default
  const etaSec = remaining / speedMS;
  return {
    predictedLocation: bus.lastKnownLocation,
    etaSeconds: Math.round(etaSec)
  };
};
