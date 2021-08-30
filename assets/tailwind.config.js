module.exports = {
  purge: ["./js/**/*.{js,ts}", "../lib/*_web/**/*.*ex"],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        "code-bg": "#111b27",
        "code-text": "#e3eaf2",
      },
      transitionProperty: {
        height: "height",
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
}
