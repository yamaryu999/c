import React, { Suspense } from 'react';
import { Canvas } from '@react-three/fiber';
import { Environment } from '@react-three/drei';
import PhysicsWorld from './PhysicsWorld';
import Effects from './Effects';

const Scene: React.FC = () => {
    return (
        <Canvas
            shadows
            camera={{ position: [0, 0, 15], fov: 45 }} // High position to look down
            style={{ width: '100%', height: '100%', background: '#050505' }}
            dpr={[1, 2]} // Performance optimization
        >
            <Suspense fallback={null}>
                <Environment preset="city" /> {/* Generic reflections for metal */}

                {/* Dynamic Light */}
                <pointLight position={[10, 10, 10]} intensity={1.5} color="#ffffff" castShadow />
                <ambientLight intensity={0.2} />

                <PhysicsWorld />
                <Effects />
            </Suspense>
        </Canvas>
    );
};

export default Scene;
