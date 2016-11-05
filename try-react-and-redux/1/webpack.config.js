module.exports = {
  entry: './src/index.js',
  output: {
    path: './public',
    filename: 'bundle.js',
    publicPath: ''
  },
  module: {
    loaders: [
      { test: /\.js$/
      , exclude: /node_modules/
      , loader: 'babel'
      , query: { presets: ['react', 'es2015'] }
      }
    ]
  },
  devServer: {
    contentBase: 'public'
  }
}