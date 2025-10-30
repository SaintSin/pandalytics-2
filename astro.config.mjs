// @ts-check

import netlify from "@astrojs/netlify";

import sitemap from "@astrojs/sitemap";
import { defineConfig } from "astro/config";
import icon from "astro-icon";

// https://astro.build/config
export default defineConfig({
	image: {
		responsiveStyles: true,
	},

	integrations: [sitemap(), icon()],
	site: "https://pandalytics-two.netlify.app",
	adapter: netlify(),
});
