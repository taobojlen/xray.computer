module.exports = {
  purge: [
    "../lib/xray_web/components/**/*.ex",
    "../lib/xray_web/components/**/*.sface",
    "../lib/xray_web/live/**/*.ex",
    "../lib/xray_web/live/**/*.leex",
    "../lib/xray_web/live/**/*.sface",
    "../lib/xray_web/templates/**/*.eex",
    "../lib/xray_web/templates/**/*.leex",
    "../lib/xray_web/views/**/*.ex",
    "./js/**/*.js",
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        "code-bg": "#111b27",
        "code-text": "#e3eaf2",
      },
      transitionProperty: {
        "height": "heigth",
      },
    },
  },
  variants: {
    extend: {
      borderRadius: ["focus-visible"],
      ringColor: ["focus-visible"],
      ringWidth: ["focus-visible"],
    },
  },
  plugins: [],
};
