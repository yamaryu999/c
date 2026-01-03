import Scene from './components/Scene';

function App() {
    return (
        <div className="w-full h-full absolute inset-0 bg-[#050505] overflow-hidden">
            {/* UI Overlay */}
            <div className="absolute top-0 left-0 w-full p-6 z-10 pointer-events-none">
                <h1 className="text-[#8B0000] font-bold text-xl tracking-[0.2em] uppercase glow-red">
                    Financial District
                </h1>
                <div className="mt-2 text-[#D4AF37] font-mono text-3xl font-light tracking-wider glow-gold">
                    ¥<span className="font-bold">66,600,000</span>
                </div>
            </div>

            {/* 3D Scene */}
            <Scene />
        </div>
    );
}

export default App;
