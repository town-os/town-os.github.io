import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://town-os.github.io',
  base: '/',
  build: {
    assets: '_assets',
  },
});
