import React from 'react';
import { EffectComposer, Bloom } from '@react-three/postprocessing';

const Effects: React.FC = () => {
    return (
        <EffectComposer>
            <Bloom
                luminanceThreshold={1.0} // Only bright stuff glows
                mipmapBlur
                intensity={1.5}
                radius={0.4}
            />
        </EffectComposer>
    );
};

export default Effects;
