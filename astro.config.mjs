import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: 'https://town-os.github.io',
  base: '/',
  i18n: {
    defaultLocale: 'en',
    locales: ['en', 'zh-Hans', 'zh-Hant'],
    routing: {
      prefixDefaultLocale: false,
    },
  },
  build: {
    assets: '_assets',
  },
  server: {
    allowedHosts: true,
  },
  vite: {
    plugins: [tailwindcss()],
  },
});
