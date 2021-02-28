defmodule Xray.ErrorReporter do
  require Logger

  def handle_event([:oban, :job, :exception], _, meta, _) do
    context = Map.take(meta, [:id, :args, :queue, :worker])
    Honeybadger.notify(meta.error, context, meta.stacktrace)
  end
end

:telemetry.attach("oban-errors", [:oban, :job, :exception], &Xray.ErrorReporter.handle_event/4, [])
