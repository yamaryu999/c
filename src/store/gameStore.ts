import { create } from 'zustand';
import { CardData } from '../types/CardType';

interface GameState {
    walletBalance: number;
    cards: CardData[];
    addCard: (card: CardData) => void;
    removeCard: (id: string) => void;
    resetDeck: () => void;
}

const initialCards: CardData[] = [
    { id: '1', rank: 'noir', position: [0, 2, 0], rotation: [0, 0, 0] },
    { id: '2', rank: 'gold', position: [0.5, 3, 0.1], rotation: [0, 0, 0.1] },
    { id: '3', rank: 'darkness', position: [-0.5, 4, 0.2], rotation: [0, 0, -0.1] },
];

export const useGameStore = create<GameState>((set) => ({
    walletBalance: 66600000,
    cards: initialCards,
    addCard: (card) => set((state) => ({ cards: [...state.cards, card] })),
    removeCard: (id) => set((state) => ({ cards: state.cards.filter((c) => c.id !== id) })),
    resetDeck: () => set({ cards: initialCards }),
}));
