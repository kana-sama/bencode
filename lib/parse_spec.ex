defmodule ParseSpec do
  @callback term(binary()) :: {:ok, any(), <<_::0>>}

  defmacro __using__(_opts) do
    quote do
      import Parser
      import ParseSpec
      alias Parser.Number
      @behaviour ParseSpec

      def parse(source) do
        Parser.run(&term/1, source)
      end

      def term(source) do
        {:error, %{rest: source}}
      end

      defoverridable term: 1
    end
  end

  defp inject_source({name, meta, nil}, source_name) do
    {name, meta, [source_name]}
  end

  defp inject_source({name, meta, args}, source_name) do
    {name, meta, [source_name | args]}
  end

  defp traverse({:__block__, _meta, exprs}, source_name) do
    List.foldr(exprs, :parse_spec@end_of_exprs, &step(&1, &2, source_name))
  end

  defp traverse(expr, source_name) do
    traverse({:__block__, [], [expr]}, source_name)
  end

  defp step({:return, _, [val]}, :parse_spec@end_of_exprs, source_name) do
    quote do
      {:ok, unquote(val), unquote(source_name)}
    end
  end

  defp step({:bind, _, [p]}, :parse_spec@end_of_exprs, source_name) do
    inject_source(p, source_name)
  end

  defp step(expr, :parse_spec@end_of_exprs, _source_name) do
    expr
  end

  defp step({:return, _, [val]}, next, source_name) do
    quote do
      {:ok, unquote(val), unquote(source_name)}
      unquote(next)
    end
  end

  defp step({:=, _, [var, {:bind, _, [p]}]}, next, source_name) do
    quote do
      case unquote(inject_source(p, source_name)) do
        {:ok, unquote(var), unquote(source_name)} -> unquote(next)
        error -> error
      end
    end
  end

  defp step({:bind, _, [p]}, next, source_name) do
    quote do
      case unquote(inject_source(p, source_name)) do
        {:ok, _, unquote(source_name)} -> unquote(next)
        error -> error
      end
    end
  end

  defp step(expr, next, _source_name) do
    quote do
      unquote(expr)
      unquote(next)
    end
  end

  defmacro defparser(name, options) do
    source_name = {:source, [], nil}

    quote do
      def unquote(inject_source(name, source_name)) do
        unquote(traverse(options[:do], source_name))
      end
    end
  end
end
