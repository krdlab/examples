const ExtractTextPlugin = require('extract-text-webpack-plugin');

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
      },
      { test: /(\.scss|\.css)$/
      , loader: ExtractTextPlugin.extract('style', 'css?sourceMap&modules&importLoaders=1&localIdentName=[name]__[local]___[hash:base64:5]!sass')
      }
    ]
  },
  plugins: [
    new ExtractTextPlugin('bundle.css', { allChunks: true }),
  ],
  devtool: 'source-map',
  devServer: {
    contentBase: 'public'
  }
}