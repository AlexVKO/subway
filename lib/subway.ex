defmodule Subway do
  defmodule Broadcast do
  end

  defmodule Event do
  end

  defmodule Import do
    defmacro defevent(event_module, do_block) do
      event_name = event_module |> Macro.to_string() |> Macro.underscore()

      quote do
        defmodule unquote(event_module) do
          use Ecto.Schema
          import Ecto.Changeset

          schema unquote(event_name) <> "_events" do
            unquote(do_block)

            timestamps()
          end

          def broadcast(params) do
            changeset =
              %unquote(event_module){}
              |> cast(params, unquote(event_module).__schema__(:fields))
              |> validate_required([])

            IO.puts("TODO: Broadcast: #{unquote(event_module)}")

            case changeset.valid? do
              true -> {:ok, changeset.changes}
              false -> {:error, changeset.errors}
            end
          end
        end

        def broadcast(unquote(event_name), params) do
          unquote(event_module).broadcast(params)
        end
      end
    end
  end

  defmacro __using__(_) do
    quote do
      import Import
    end
  end
end
