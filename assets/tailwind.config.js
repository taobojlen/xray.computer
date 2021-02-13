module.exports = {
  purge: [
    "../lib/xray_web/live/**/*.ex",
    "../lib/xray_web/live/**/*.leex",
    "../lib/xray_web/templates/**/*.eex",
    "../lib/xray_web/templates/**/*.leex",
    "../lib/xray_web/views/**/*.ex",
    "./js/**/*.js",
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
