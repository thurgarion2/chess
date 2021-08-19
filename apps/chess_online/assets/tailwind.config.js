module.exports = {
  purge: [
    '../lib/**/*.ex',
    '../lib/**/*.leex',
    '../lib/**/*.eex',
    './js/**/*.js'
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        'tile-black': '#512A2A',
        'tile-white': '#7C4C3E',
        'tile-hover-white': '#595959',
        'tile-hover-black': '#363636',
        'selected-green': '#6EE91B'
      }
    }
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
