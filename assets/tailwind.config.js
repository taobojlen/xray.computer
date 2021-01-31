module.exports = {
  purge: [
    "../lib/diff_web/live/**/*.ex",
    "../lib/diff_web/live/**/*.leex",
    "../lib/diff_web/templates/**/*.eex",
    "../lib/diff_web/templates/**/*.leex",
    "../lib/diff_web/views/**/*.ex",
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
