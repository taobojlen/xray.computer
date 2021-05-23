# defmodule Xray.Source.DiffFetcher do
#   use Oban.Worker,
#     queue: :source_fetcher,
#     unique: [period: :infinity]

#   require Logger
#   alias Xray.{Packages, Source, Storage}

#   def perform(%Oban.Job{args: %{"first_id" => first_id, "second_id" => second_id}}) do
#     :ok
#   end
# end
