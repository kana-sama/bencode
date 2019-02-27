defmodule Parser do
  def run(parser, source) do
    case parser.(source) do
      {:ok, value, ""} ->
        {:ok, value}

      {:ok, _, _} ->
        {:error, :not_eof}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def run(module, func, source) do
    Parser.run(&apply(module, func, [&1]), source)
  end

  defmacro a <|> b do
    quote do
      case unquote(a) do
        {:ok, _value, _s} = result ->
          result

        {:error, _reason} ->
          unquote(b)
      end
    end
  end

  def char(s, <<char>>) do
    with <<^char, s::binary>> <- s do
      {:ok, char, s}
    else
      _ -> {:error, %{rest: s}}
    end
  end

  def take(s, count) do
    if String.length(s) < count do
      {:error, %{rest: s}}
    else
      {value, s} = String.split_at(s, count)
      {:ok, value, s}
    end
  end

  def optional(s, parser) do
    case parser.(s) do
      {:ok, value, s} ->
        {:ok, {:some, value}, s}

      {:error, _reason} ->
        {:ok, :none, s}
    end
  end

  def many(s, parser) do
    do_many(s, parser, [])
  end

  defp do_many(s, parser, values) do
    case parser.(s) do
      {:ok, value, s} ->
        do_many(s, parser, [value | values])

      _ ->
        {:ok, Enum.reverse(values), s}
    end
  end
end
