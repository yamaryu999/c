// Simple synthesizer for metallic clinks using Web Audio API

// Shared context
let audioCtx: AudioContext | null = null;

export const playClink = (velocity: number) => {
    try {
        if (!audioCtx) {
            audioCtx = new (window.AudioContext || (window as any).webkitAudioContext)();
        }

        // Resume context if suspended (browser autoplay policy)
        if (audioCtx.state === 'suspended') {
            audioCtx.resume();
        }

        // Velocity usually ranges 0 to 20ish? Clamp 0-1
        const intensity = Math.min(Math.max(velocity / 10, 0), 1);
        if (intensity < 0.05) return; // Too quiet, don't play

        const t = audioCtx.currentTime;

        // Oscillator 1: Metallic Ring (High Sine)
        const osc1 = audioCtx.createOscillator();
        osc1.type = 'sine';
        // Randomize pitch slightly for variation
        osc1.frequency.value = 2000 + Math.random() * 500;

        // Oscillator 2: Impact (low square/saw)
        const osc2 = audioCtx.createOscillator();
        osc2.type = 'triangle';
        osc2.frequency.value = 300 + Math.random() * 100;

        // Gain Envelopes
        const gain1 = audioCtx.createGain();
        const gain2 = audioCtx.createGain();

        // Master Gain for volume
        const masterGain = audioCtx.createGain();
        masterGain.gain.value = intensity * 0.5; // Master volume scaling

        // Connections
        osc1.connect(gain1);
        osc2.connect(gain2);
        gain1.connect(masterGain);
        gain2.connect(masterGain);
        masterGain.connect(audioCtx.destination);

        // Envelope 1 (Ring) - Long decay
        gain1.gain.setValueAtTime(0, t);
        gain1.gain.linearRampToValueAtTime(0.8, t + 0.01);
        gain1.gain.exponentialRampToValueAtTime(0.01, t + 0.5);

        // Envelope 2 (Impact) - Short thud
        gain2.gain.setValueAtTime(0, t);
        gain2.gain.linearRampToValueAtTime(0.6, t + 0.01);
        gain2.gain.exponentialRampToValueAtTime(0.01, t + 0.1);

        // Start/Stop
        osc1.start(t);
        osc2.start(t);

        osc1.stop(t + 0.6);
        osc2.stop(t + 0.6);

    } catch (e) {
        console.error("Audio Playback Error", e);
    }
};
