export type CardRank = 'noir' | 'gold' | 'darkness';

export interface CardData {
    id: string;
    rank: CardRank;
    position: [number, number, number];
    rotation: [number, number, number];
}
