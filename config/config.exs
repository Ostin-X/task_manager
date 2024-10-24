# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

defmodule ConfigHelper do
  @moduledoc """
  Helper for importing config files
  """
  @doc """
    Imports config file if it exists
  """
  def import_if_exists(config_path) do
    full_path =
      File.cwd!()
      |> Path.join(config_path)

    if File.exists?(full_path) do
      import_config(full_path)
    else
      IO.warn("Config file #{config_path} does not exist. Skipping import.")
    end
  end
end

config :task_manager,
  ecto_repos: [TaskManager.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :task_manager, TaskManagerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: TaskManagerWeb.ErrorHTML, json: TaskManagerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TaskManager.PubSub,
  live_view: [signing_salt: "Mynx4lsk"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :task_manager, TaskManager.Mailer, adapter: Swoosh.Adapters.Local

ConfigHelper.import_if_exists("/deps/moon/config/surface.exs")

config :surface, :components, [
  {Moon.Design.Tooltip.Content, propagate_context_to_slots: true},
  {Surface.Components.Form.ErrorTag, default_translator: {TaskManagerWeb.ErrorHelpers, :translate_error}}
]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  task_manager: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  task_manager: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
