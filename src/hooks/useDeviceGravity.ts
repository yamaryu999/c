import { useEffect, useState } from 'react';
import * as THREE from 'three';

/**
 * Returns a normalized gravity vector based on device orientation.
 * Default gravity is down (0, -9.81, 0) if no sensors.
 */
export function useDeviceGravity() {
    const [gravity, setGravity] = useState<[number, number, number]>([0, -9.81, 0]);

    useEffect(() => {
        const handleOrientation = (event: DeviceOrientationEvent) => {
            // Beta: Front-to-back tilt [-180, 180]
            // Gamma: Left-to-right tilt [-90, 90]
            const { beta, gamma } = event;

            if (beta === null || gamma === null) return;

            // Convert degrees to gravity vector
            // 9.81 is standard earth gravity
            const G = 9.81;

            // Simple mapping:
            // Tilted right (gamma > 0) -> Gravity X > 0
            // Tilted forward (beta > 0) -> Gravity Y < 0

            const radGamma = THREE.MathUtils.degToRad(gamma);
            const radBeta = THREE.MathUtils.degToRad(beta);

            const x = Math.sin(radGamma) * G;
            const y = -Math.sin(radBeta) * G;
            // Z component handles the rest to maintain magnitude G, but we mostly care about XY plane for UI
            // However, 3D cards might fall "away" if we aren't careful.
            // Let's keep Z somewhat constant or derived to keep things pressed against the 'back'? 
            // Actually, for a 2D-ish card game, we often want gravity mostly in XY.

            setGravity([x * 2, y * 2, 0]); // Multiplied for snappier feel
        };

        if (window.DeviceOrientationEvent) {
            window.addEventListener('deviceorientation', handleOrientation);
        }

        return () => {
            window.removeEventListener('deviceorientation', handleOrientation);
        };
    }, []);

    return gravity;
}
