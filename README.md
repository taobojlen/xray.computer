# X-Ray

# Configuration

Xray expects the following environment variables:

- `SECRET_KEY_BASE` for Phoenix (generate with `mix phx.gen.secret`)
- `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` if using S3 for file storage
- `HONEYBADGER_API_KEY` if using Honeybadger for error tracking
- `ADMIN_PASSWORD` to access the LiveDashboard

# Developing

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm --prefix assets install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.