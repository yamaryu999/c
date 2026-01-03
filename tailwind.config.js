/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                obsidian: '#050505',
                blood: '#8B0000',
                gold: '#D4AF37',
            },
        },
    },
    plugins: [],
}
