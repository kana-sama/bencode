defmodule Bencode do
  use ParseSpec

  @impl ParseSpec
  def term(s) do
    int(s) <|> string(s) <|> list(s) <|> dict(s)
  end

  defparser int do
    bind(char(?i))
    value = bind(Number.signed())
    bind(char(?e))
    return(value)
  end

  defparser string do
    count = bind(Number.unsigned())
    bind(char(?:))
    value = bind(take(count))
    return(value)
  end

  defparser list do
    bind(char(?l))
    elements = bind(many(&term/1))
    bind(char(?e))
    return(elements)
  end

  defparser dict do
    bind(char(?d))
    pairs = bind(many(&pair/1))
    bind(char(?e))
    return(Enum.into(pairs, Map.new()))
  end

  defparser pair do
    a = bind(term)
    b = bind(term)
    return({a, b})
  end
end
