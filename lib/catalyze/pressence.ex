defmodule Catalyze.Presence do
  use Phoenix.Presence,
    otp_app: :catalyze,
    pubsub_server: Catalyze.PubSub
end
