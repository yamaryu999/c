import React from 'react';
import { Physics } from '@react-three/rapier';
import { useDeviceGravity } from '../hooks/useDeviceGravity';
import Boundaries from './Boundaries';

import { useGameStore } from '../store/gameStore';
import Card from './Card';

const PhysicsWorld: React.FC = () => {
    const gravity = useDeviceGravity();
    const cards = useGameStore((state) => state.cards);

    return (
        <Physics gravity={gravity}>
            <Boundaries />

            {cards.map((card) => (
                <Card key={card.id} {...card} />
            ))}

        </Physics>
    );
};

export default PhysicsWorld;
