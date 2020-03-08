# A guinea pig event contex
defmodule UserEvents do
  use Subway, subscribers: [GenSubscriber]

  defevent ListingFavorited do
    field(:user_id, :string, required: true)
    field(:listing_id, :string)
  end

  defevent MessageSent do
    field(:user_id, :string)
    field(:content, :string, required: true)
  end
end

# A guinea pig subscriber.
defmodule GenSubscriber do
  alias Subway.Subscriber
  @behaviour Subscriber

  @impl Subscriber
  def supported_event?(event_name) do
    Regex.match?(~r/message_sent/, event_name)
  end

  @impl Subscriber
  def handle(_event_name, %{payload: payload}) do
    send(self(), Map.merge(payload, %{from: "GenSubscriber"}))

    :ok
  end
end

defmodule SubwayTest do
  use ExUnit.Case

  test "it returns the data when everything is OK" do
    case UserEvents.broadcast("listing_favorited", %{user_id: "2", listing_id: "1"}) do
      {:ok, payload} -> send(self(), payload)
    end

    assert_receive %{listing_id: "1", user_id: "2"}
  end

  test "it returns the errors when it is not valid" do
    case UserEvents.broadcast("message_sent", %{user_id: 1}) do
      {:error, errors} -> send(self(), errors)
    end

    assert_receive [
      {
        :content,
        {"can't be blank", [validation: :required]}
      },
      {
        :user_id,
        {"is invalid", [type: :string, validation: :cast]}
      }
    ]
  end

  test "subscriber receives the event" do
    # This is supported by GenSubscriber
    {:ok, _event} = UserEvents.broadcast("message_sent", %{user_id: "1", content: "Content"})

    # This is NOT supported by GenSubscriber
    {:ok, _event} = UserEvents.broadcast("listing_favorited", %{listing_id: "2", user_id: "2"})

    assert_receive %{user_id: "1", content: "Content", from: "GenSubscriber"}
  end
end
