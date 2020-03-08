defmodule Subway do
  @moduledoc """
    Adds the ability to create **contexts** and define events inside of it.

    ### Example

      defmodule UserEvents do
        use Subway, subscribers: [GenSubscriber]

        defevent MessageSent do
          field(:user_id, :string)
          field(:content, :string, required: true)
        end
      end

    The MessageSent event will be triggered like so:

      UserEvents.MessageSent.broadcast(%{user_id: 1, content: "Message content"})
      # OR
      UserEvents.broadcast("message_sent", %{user_id: 1, content: "Message content"})

    If the payload is valid it will broadcast to predefined subscribers,
    this is an example of a subscriber:

    defmodule GenSubscriber do
      def handle_event?(event_name) do
         # Check inside a list of events or with a Regex.
      end

      def handle(event_name, %{payload: payload, changeset: changeset}) do
        # do your logic here...
      end
    end
  """

  defmacro __using__(opts \\ []) do
    quote do
      import Subway.EventBuilder

      @doc """
        Notifies the subscribers in case it supports the given event
      """
      def notify_subscribers(event_name, %{payload: _, changeset: _} = params) do
        Enum.each(unquote(opts[:subscribers]), fn subscriber_mod ->
          if subscriber_mod.supported_event?(event_name) do
            subscriber_mod.handle(event_name, params)
          end
        end)
      end
    end
  end
end
