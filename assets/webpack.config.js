const path = require("path")
const glob = require("glob")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin")
const CopyWebpackPlugin = require("copy-webpack-plugin")

module.exports = (env, options) => {
  const devMode = options.mode !== "production"

  return {
    optimization: {
      minimizer: ["...", new CssMinimizerPlugin()],
    },
    cache: {
      type: "filesystem",
      allowCollectingMemory: true,
      buildDependencies: {
        config: [__filename],
      },
    },
    entry: {
      app: glob.sync("./vendor/**/*.js").concat(["./js/app.ts"]),
    },
    output: {
      filename: "[name].js",
      path: path.resolve(__dirname, "../priv/static/js"),
      publicPath: "/js/",
    },
    devtool: devMode ? "source-map" : undefined,
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: "babel-loader",
          },
        },
        {
          test: /\.ts$/,
          exclude: /node_modules/,
          use: [{ loader: "babel-loader" }, { loader: "ts-loader" }],
        },
        {
          test: /\.css$/,
          use: [MiniCssExtractPlugin.loader, "css-loader", "postcss-loader"],
        },
      ],
    },
    resolve: {
      extensions: [".ts", ".js"],
    },
    plugins: [
      new MiniCssExtractPlugin({ filename: "../css/app.css" }),
      new CopyWebpackPlugin({
        patterns: [{ from: "static/", to: "../" }],
      }),
    ],
  }
}
