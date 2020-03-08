defmodule Subway.EventBuilder do
  defmacro defevent(event_mod, do_block) do
    event_name = event_mod |> Macro.to_string() |> Macro.underscore()
    event_context = __CALLER__.module

    quote do
      defmodule unquote(event_mod) do
        use Subway.Event
        use Ecto.Schema
        import Ecto.Changeset

        setupevent(unquote(do_block))

        schema unquote(event_name) <> "_events" do
          Module.get_attribute(unquote(event_mod), :subway_fields)
          |> Enum.each(fn {name, type} ->
            Ecto.Schema.field(name, type)
          end)
        end

        def broadcast(params) do
          changeset =
            %unquote(event_mod){}
            |> cast(params, unquote(event_mod).__schema__(:fields))
            |> validate_required(@subway_required_fields)

          case changeset.valid? do
            true ->
              unquote(event_context).notify_subscribers(unquote(event_name), %{
                payload: changeset.changes,
                changeset: changeset
              })

              {:ok, changeset.changes}

            false ->
              {:error, changeset.errors}
          end
        end
      end

      def broadcast(unquote(event_name), params) do
        unquote(event_mod).broadcast(params)
      end
    end
  end
end
