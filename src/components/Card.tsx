import React, { useRef, useMemo } from 'react';

import { RigidBody, RapierRigidBody } from '@react-three/rapier';
import { RoundedBox } from '@react-three/drei';
import { useDrag } from '@use-gesture/react';

import { CardRank } from '../types/CardType';
import { playClink } from '../utils/audio';

interface CardProps {
    id: string;
    rank: CardRank;
    position: [number, number, number];
    rotation: [number, number, number];
}

const Card: React.FC<CardProps> = ({ rank, position, rotation }) => {
    const rigidBodyRef = useRef<RapierRigidBody>(null);

    // Card Dimensions (Credit Card Ratio ~ 1.586)
    const width = 2; // Arbitrary 3D units
    const height = width / 1.586;
    const thickness = 0.05;

    // Materials based on Rank
    const materialProps = useMemo(() => {
        switch (rank) {
            case 'gold':
                return { color: '#D4AF37', roughness: 0.3, metalness: 1.0 };
            case 'darkness':
                return { color: '#000000', roughness: 0.1, metalness: 0.9 };
            case 'noir':
            default:
                return { color: '#1a1a1a', roughness: 0.8, metalness: 0.5 };
        }
    }, [rank]);

    // Drag Logic
    const bind = useDrag(({ active, movement: [x, y], memo = [0, 0] }) => {
        if (!rigidBodyRef.current) return;

        // Wake up the body
        rigidBodyRef.current.wakeUp();

        if (active) {
            // Dragging: Move towards the cursor (Screen space to World space approximation needed)
            // For now, simpler Impulse approach:
            // Calculate velocity based on movement delta ??
            // Or simply Kinematic control while dragging?
            // Kinematic is better for "holding", but Dynamic is better for "throwing".

            // Better "Throw" feel: Apply force towards the drag target
            // But for direct 1:1 control we touch/mouse plane.

            // Let's try Impulse-based "Pull" to cursor.
            // Or actually, simple impulse on drag end (flick) and maybe just small nudges during drag?

            // The prompt asked for "Drag and Throw".
            // A common technique is to set the velocity directly to match mouse movement.

            // Let's just apply an impulse based on the movement delta for now to simulate "pushing".
            // A full "pick up and drag" needs raycasting to plane.

            const impulseScale = 0.02;
            rigidBodyRef.current.applyImpulse({ x: x * impulseScale, y: -y * impulseScale, z: 0 }, true);

        }

        return memo;
    }, { filterTaps: true });

    return (
        // eslint-disable-next-line @typescript-eslint/ban-ts-comment
        // @ts-ignore
        <RigidBody
            ref={rigidBodyRef}
            position={position}
            rotation={rotation}
            colliders="cuboid"
            restitution={0.2} // "Thud"
            friction={0.5}
            density={5.0} // Heavy
            {...bind()}
            onCollisionEnter={() => {
                // Calculate relative velocity magnitude estimate
                // Rapier doesn't give relative velocity easily in collision event, 
                // but we can check the impulse or just random for now?
                // Actually payload might have totalForce or impulse.
                // Let's use a simple randomize/threshold or just play if it hits 'hard' 
                // For accurate velocity we need the other body's velocity.
                // Let's guess based on our own velocity.
                if (rigidBodyRef.current) {
                    const vel = rigidBodyRef.current.linvel();
                    const speed = Math.sqrt(vel.x ** 2 + vel.y ** 2 + vel.z ** 2);
                    playClink(speed + 1); // Add base intensity
                }
            }}
        >
            <RoundedBox args={[width, height, thickness]} radius={0.1} smoothness={4}>
                <meshStandardMaterial {...materialProps} />
            </RoundedBox>
        </RigidBody>
    );
};

export default Card;
