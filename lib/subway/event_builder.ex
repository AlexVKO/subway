defmodule Subway.EventBuilder do
  @moduledoc ~S"""
    Defines an event.

    An event is a new module, programmatically created inside the caller's namespace.
    This new event is built upon an Ecto model(making validation and persistence easier)

    ## Example:

      defmodule UserEvents do
        use Subway

        defevent MessageSent do
          field(:user_id, :string)
          field(:content, :string, required: true)
        end
      end
  """

  defmacro defevent(event_mod, do_block) do
    event_name = event_mod |> Macro.to_string() |> Macro.underscore()
    event_context_mod = __CALLER__.module

    quote do
      defmodule unquote(event_mod) do
        use Subway.Event
        use Ecto.Schema
        import Ecto.Changeset

        setupevent(unquote(do_block))

        @doc """
          Creates a new schema using Ecto.Schema api
        """
        schema unquote(event_name) <> "_events" do
          Module.get_attribute(unquote(event_mod), :subway_fields)
          |> Enum.each(fn {name, type} ->
            Ecto.Schema.field(name, type)
          end)
        end

        @doc """
          Validates the event's payload, and in case it is valid, it broadcasts
          the payload to the subscribers

          ## Example:

            UserEvents.MessageSent.broadcast(%{user_id: 1, content: "Message content"})
        """
        def broadcast(params) do
          changeset =
            %unquote(event_mod){}
            |> cast(params, unquote(event_mod).__schema__(:fields))
            |> validate_required(@subway_required_fields)

          case changeset.valid? do
            true ->
              unquote(event_context_mod).notify_subscribers(unquote(event_name), %{
                payload: changeset.changes,
                changeset: changeset
              })

              {:ok, changeset.changes}

            false ->
              {:error, changeset.errors}
          end
        end
      end

      @doc """
        Delegates broadcast/2 to event module.

          ## Example:

            # Instead of call this:
            UserEvents.MessageSent.broadcast(%{user_id: 1, content: "Message content"})

            # This method allows you to call this:
            UserEvents.broadcast("message_sent", %{user_id: 1, content: "Message content"})
      """
      def broadcast(unquote(event_name), params) do
        unquote(event_mod).broadcast(params)
      end
    end
  end
end
