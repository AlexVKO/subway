defmodule Subway do
  defmacro __using__(opts \\ []) do
    quote do
      import Subway.EventBuilder

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
