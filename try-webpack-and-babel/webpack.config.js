var webpack = require('webpack');
var HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: './src/app.js',
  output: {
    path: 'dist',
    filename: 'bundle.js'
  },
  resolve: {
    extensions: ["", ".webpack.js", ".web.js", ".js", ".yml"]
  },
  module: {
    loaders: [
      { test: /\.yml$/
      , loader: 'json!yaml'
      },
      { test: /\.js$/
      , loader: 'babel'
      , query: { presets: ['react', 'es2015'] }
      }
    ]
  },
  plugins: [
    new webpack.optimize.UglifyJsPlugin(),
    new HtmlWebpackPlugin({ title: "Sample Page" })
  ],
  devtool: 'source-map'
};
