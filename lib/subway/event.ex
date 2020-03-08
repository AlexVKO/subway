defmodule Subway.Event do
  @moduledoc ~S"""
    Macros for using inside an event, it monstly stores configurations in the module so 
    that the EventBuilder can use it for building fields, validations and so forth.
  """

  @doc """
    Evaluates the block given from the event definition.
  """
  defmacro setupevent(block) do
    quote do
      unquote(block)

      def __events__(:fields), do: Module.get_attribute(__MODULE__, :subway_fields)

      def __events__(:required_fields),
        do: Module.get_attribute(__MODULE__, :subway_required_fields)
    end
  end

  @doc """
    Stores the field informations to later be used from EventBuilder
  """
  defmacro field(name, type \\ :string, opts \\ []) do
    quote do
      Module.put_attribute(__MODULE__, :subway_fields, {unquote(name), unquote(type)})

      if unquote(opts[:required]) do
        Module.put_attribute(__MODULE__, :subway_required_fields, unquote(name))
      end
    end
  end

  @doc """
    Imports this module and register configuration attributes
  """
  defmacro __using__(_) do
    quote do
      import Subway.Event

      Module.register_attribute(__MODULE__, :subway_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :subway_required_fields, accumulate: true)
    end
  end
end
