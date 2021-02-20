# X-Ray

## To do
- [x] Download full list of packages daily & use that for search
  - Stream download from npm since it's a large JSON file
- [x] Cache responses from registry
- [ ] Add S3 storage
- [ ] Write more tests
- [ ] Implement diff
- [ ] Add cronjob to clear tmp regularly
- [ ] Put cursor in search field immediately when viewing page
- [ ] Maybe: support for going directly to dependency diff from lockfile diff

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
