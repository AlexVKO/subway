defmodule Subway.Subscriber do
  @moduledoc ~S"""
    Behaviours to implement subscribers.
  """

  @doc """
    Checks if the broadcasted event is supported

    Example:

      def supported_event?(event_name) do
        regex = ~r/message/

        Regex.match?(regex, event_name)
      end
  """
  @callback supported_event?(String.t()) :: boolean()

  @doc """
    Handles the supported_event

    Example:

      def handle(event_name, %{changeset: changeset, payload: payload}) do
        # Whatever logic you want to perform
        :ok
      end
  """
  @callback handle(String.t(), Map.t()) :: :ok
end
