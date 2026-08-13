export const defaultLang = 'en';

/**
 * Supported locales. The keys are the URL prefixes (except for `defaultLang`,
 * which is served without a prefix) and the BCP 47 codes used for `<html lang>`
 * and `hreflang`.
 */
export const languages = {
  en: { label: 'English', short: 'EN' },
  'es-MX': { label: 'Español (México)', short: 'MX' },
  'es-ES': { label: 'Español (España)', short: 'ES' },
  'zh-CN': { label: '简体中文', short: '简' },
  'zh-TW': { label: '繁體中文', short: '繁' },
  ja: { label: '日本語', short: 'JA' },
} as const;

export type Lang = keyof typeof languages;

export const localeCodes = Object.keys(languages) as Lang[];

/** Locales that live under a URL prefix — everything but the default. */
export const prefixedLocales = localeCodes.filter((l) => l !== defaultLang);

export const ui = {
  en: {
    'site.description':
      'Town OS — Your Cloud in Your Closet. A self-hosted platform that runs entirely from a USB drive.',
    'nav.try': 'Try it out',
    'nav.toggle': 'Toggle navigation',
    'nav.home': 'Home',
    'nav.guide': 'Guide',
    'nav.concepts': 'Concepts',
    'nav.packaging': 'Packaging',
    'nav.api': 'API',
    'nav.screenshots': 'Screenshots',
    'nav.community': 'Community',
    'nav.source': 'Source Code',
    'lang.label': 'Language',
    'footer.tagline': 'Your Cloud in Your Closet',
    'footer.gitea': 'Gitea',
    'footer.packages': 'Packages',
    'footer.github': 'GitHub',
    'footer.license': 'Licensed under GNU Affero GPL 3.0',
  },
  'es-MX': {
    'site.description':
      'Town OS — Tu nube en tu clóset. Una plataforma autoalojada que corre por completo desde una memoria USB.',
    'nav.try': 'Pruébalo',
    'nav.toggle': 'Alternar navegación',
    'nav.home': 'Inicio',
    'nav.guide': 'Guía',
    'nav.concepts': 'Conceptos',
    'nav.packaging': 'Empaquetado',
    'nav.api': 'API',
    'nav.screenshots': 'Capturas',
    'nav.community': 'Comunidad',
    'nav.source': 'Código fuente',
    'lang.label': 'Idioma',
    'footer.tagline': 'Tu nube en tu clóset',
    'footer.gitea': 'Gitea',
    'footer.packages': 'Paquetes',
    'footer.github': 'GitHub',
    'footer.license': 'Bajo licencia GNU Affero GPL 3.0',
  },
  'es-ES': {
    'site.description':
      'Town OS — Tu nube en tu armario. Una plataforma autoalojada que se ejecuta por completo desde una memoria USB.',
    'nav.try': 'Pruébalo',
    'nav.toggle': 'Alternar navegación',
    'nav.home': 'Inicio',
    'nav.guide': 'Guía',
    'nav.concepts': 'Conceptos',
    'nav.packaging': 'Empaquetado',
    'nav.api': 'API',
    'nav.screenshots': 'Capturas',
    'nav.community': 'Comunidad',
    'nav.source': 'Código fuente',
    'lang.label': 'Idioma',
    'footer.tagline': 'Tu nube en tu armario',
    'footer.gitea': 'Gitea',
    'footer.packages': 'Paquetes',
    'footer.github': 'GitHub',
    'footer.license': 'Bajo licencia GNU Affero GPL 3.0',
  },
  'zh-CN': {
    'site.description':
      'Town OS——把云装进你家的储物间。完全从 U 盘运行的自托管平台。',
    'nav.try': '立即试用',
    'nav.toggle': '切换导航',
    'nav.home': '首页',
    'nav.guide': '指南',
    'nav.concepts': '核心概念',
    'nav.packaging': '打包格式',
    'nav.api': 'API',
    'nav.screenshots': '界面截图',
    'nav.community': '社区',
    'nav.source': '源代码',
    'lang.label': '语言',
    'footer.tagline': '把云装进你家的储物间',
    'footer.gitea': 'Gitea',
    'footer.packages': '软件包',
    'footer.github': 'GitHub',
    'footer.license': '采用 GNU Affero GPL 3.0 许可证',
  },
  'zh-TW': {
    'site.description':
      'Town OS——把雲端搬進你家的儲藏室。完全從 USB 隨身碟執行的自架平台。',
    'nav.try': '立即試用',
    'nav.toggle': '切換導覽',
    'nav.home': '首頁',
    'nav.guide': '指南',
    'nav.concepts': '核心概念',
    'nav.packaging': '封裝格式',
    'nav.api': 'API',
    'nav.screenshots': '介面截圖',
    'nav.community': '社群',
    'nav.source': '原始碼',
    'lang.label': '語言',
    'footer.tagline': '把雲端搬進你家的儲藏室',
    'footer.gitea': 'Gitea',
    'footer.packages': '套件',
    'footer.github': 'GitHub',
    'footer.license': '依 GNU Affero GPL 3.0 授權',
  },
  ja: {
    'site.description':
      'Town OS — あなたのクラウドを、あなたの物置に。USB メモリだけで動作するセルフホスト型プラットフォーム。',
    'nav.try': '試してみる',
    'nav.toggle': 'ナビゲーションを開閉',
    'nav.home': 'ホーム',
    'nav.guide': 'ガイド',
    'nav.concepts': '基本概念',
    'nav.packaging': 'パッケージング',
    'nav.api': 'API',
    'nav.screenshots': 'スクリーンショット',
    'nav.community': 'コミュニティ',
    'nav.source': 'ソースコード',
    'lang.label': '言語',
    'footer.tagline': 'あなたのクラウドを、あなたの物置に',
    'footer.gitea': 'Gitea',
    'footer.packages': 'パッケージ',
    'footer.github': 'GitHub',
    'footer.license': 'GNU Affero GPL 3.0 ライセンスの下で提供',
  },
} as const;

const base = import.meta.env.BASE_URL;

/** Normalise BASE_URL to a leading-and-trailing-slash form, e.g. `/` or `/foo/`. */
export function baseUrl(): string {
  return base.endsWith('/') ? base : `${base}/`;
}

/** Determine the active locale from the request URL. */
export function getLangFromUrl(url: URL): Lang {
  const rest = url.pathname.slice(baseUrl().length);
  const segment = rest.split('/')[0];
  return (prefixedLocales as string[]).includes(segment) ? (segment as Lang) : defaultLang;
}

/** Strip the base and any locale prefix, returning a path like `guide/`. */
export function stripLang(url: URL): string {
  let rest = url.pathname.slice(baseUrl().length);
  const segment = rest.split('/')[0];
  if ((prefixedLocales as string[]).includes(segment)) {
    rest = rest.slice(segment.length + 1);
  }
  return rest;
}

/**
 * Build an absolute site path for `path` (given without base or locale, e.g.
 * `guide/` or `guide/#quick-start`) in `lang`.
 */
export function localizePath(path: string, lang: Lang = defaultLang): string {
  const clean = path.replace(/^\//, '');
  return lang === defaultLang ? `${baseUrl()}${clean}` : `${baseUrl()}${lang}/${clean}`;
}

/** Translation lookup for a locale, falling back to English. */
export function useTranslations(lang: Lang) {
  return function t(key: keyof (typeof ui)['en']): string {
    return (ui[lang] as Record<string, string>)[key] ?? ui[defaultLang][key];
  };
}
