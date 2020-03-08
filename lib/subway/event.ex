defmodule Subway.Event do
  defmacro setupevent(block) do
    quote do
      unquote(block)

      def __events__(:fields), do: Module.get_attribute(__MODULE__, :subway_fields)
      def __events__(:required_fields), do: Module.get_attribute(__MODULE__, :subway_required_fields)
    end
  end

  defmacro field(name, type \\ :string, opts \\ []) do
    quote do
      Module.put_attribute(__MODULE__, :subway_fields, {unquote(name), unquote(type)})

      if unquote(opts[:required]) do
        Module.put_attribute(__MODULE__, :subway_required_fields, unquote(name))
      end
    end
  end

  defmacro __using__(_) do
    quote do
      import Subway.Event

      Module.register_attribute(__MODULE__, :subway_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :subway_required_fields, accumulate: true)
    end
  end
end
