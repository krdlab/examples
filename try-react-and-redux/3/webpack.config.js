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
      , query: {
          presets: ['es2015', 'react']
        , plugins: ['transform-object-rest-spread']
        }
      }
    ]
  },
  devtool: 'source-map',
  devServer: {
    contentBase: 'public'
  }
}