import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: 'https://town-os.github.io',
  base: '/',
  build: {
    assets: '_assets',
  },
  vite: {
    plugins: [tailwindcss()],
  },
});
