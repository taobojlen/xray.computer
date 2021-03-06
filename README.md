# X-Ray

## To do
- [x] Download full list of packages daily & use that for search
  - Stream download from npm since it's a large JSON file
- [x] Cache responses from registry
- [x] Add S3 storage
- [x] Make version loading async
- [ ] Keep file selector at top of screen
- [ ] Include more detail in source loading state (progress bar?)
- [ ] Write more tests
- [ ] Implement diff
- [ ] Add cronjob to clear tmp regularly
- [ ] Put cursor in search field immediately when viewing page
- [ ] Maybe: support for going directly to dependency diff from lockfile diff

# Configuration

Xray expects the following environment variables:

- `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` if using S3 for file storage
- `HONEYBADGER_API_KEY` if using Honeybadger for error tracking

# Developing

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.