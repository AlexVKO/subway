# Subway

An minimalist event bus library for Elixir.

## Simple usage in 4 steps:

### 1) Create your first event context:
```elixir
defmodule YourApplication.UserEvents do
  use EventBus
end
```

### 2) Define your events into it:
```elixir
defmodule YourApplication.UserEvents do
  use EventBus

  defevent "listing_favorited" do # <- You can have multiple events like this
    field :user_id, :integer # <- Ecto api
    field :listing_id, :integer

    timestamps
  end
end
```

### 3) Define the subscribers(who will be notified when these event happen):
```elixir
defmodule YourApplication.UserEvents do
  alias YourApplication.Events.Subscribers

  use EventBus,
    subscribers: [
      # Subscribers are simple modules that implement supported_event?/1 and handle_event/1
      Subscribers.PersistOnMongoDB,
      Subscribers.SendToHubspot,
      Subscribers.TriggerClientWebhook,
      Subscribers.EnqueueToRedis,
    ] 

  # These fields will be merged to the event's fields defined in this context.
  @common_fields %{
    user_id: :integer,
    listing_id: :integer,
  }

  defevent "listing_favorited" do, end
  defevent "listing_unfavorited" do, end
end
```

### 4) Start tracking!
```elixir
  alias YourApplication.UserEvents

  # params = %{ user_id: 1, listing_id: 1 })
  case UserEvents.notify("listing_favorited", params) do
    {:ok, event} -> "Yay! The event was broadcasted successfully"
    {:error, event} -> "Validation errors is included in the event changeset"
  end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `subway` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:subway, "~> 0.1.0"}
  ]
end
```

