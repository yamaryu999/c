import React from 'react';
import { CuboidCollider, RigidBody } from '@react-three/rapier';
import { useThree } from '@react-three/fiber';

const Boundaries: React.FC = () => {
    const { viewport } = useThree();
    const width = viewport.width;
    const height = viewport.height;

    // Thickness of the invisible walls
    const thickness = 2;

    return (
        <group>
            {/* Bottom */}
            <RigidBody type="fixed" position={[0, -height / 2 - thickness / 2, 0]}>
                <CuboidCollider args={[width / 2, thickness / 2, 5]} />
            </RigidBody>

            {/* Top */}
            <RigidBody type="fixed" position={[0, height / 2 + thickness / 2, 0]}>
                <CuboidCollider args={[width / 2, thickness / 2, 5]} />
            </RigidBody>

            {/* Left */}
            <RigidBody type="fixed" position={[-width / 2 - thickness / 2, 0, 0]}>
                <CuboidCollider args={[thickness / 2, height / 2, 5]} />
            </RigidBody>

            {/* Right */}
            <RigidBody type="fixed" position={[width / 2 + thickness / 2, 0, 0]}>
                <CuboidCollider args={[thickness / 2, height / 2, 5]} />
            </RigidBody>

            {/* Backboard (to keep cards from falling into void Z) */}
            <RigidBody type="fixed" position={[0, 0, -1]}>
                <CuboidCollider args={[width, height, 0.5]} />
            </RigidBody>

            {/* Front Glass (invisible, keeps cards from falling towards camera) */}
            <RigidBody type="fixed" position={[0, 0, 2]}>
                <CuboidCollider args={[width, height, 0.5]} />
            </RigidBody>

        </group>
    );
};

export default Boundaries;
