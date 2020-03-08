defmodule UserEvents do
  use Subway

  defevent ListingFavorited do
    field(:listing_id, :string)
  end
end

defmodule GenSubscriber do
end

defmodule SubwayTest do
  use ExUnit.Case

  test "it creates an changeset with the proper " do
    case UserEvents.broadcast("listing_favorited", %{listing_id: "1"}) do
      {:ok, payload} -> IO.inspect(payload)
      {:error, errors} -> IO.inspect(errors)
    end
  end
end
