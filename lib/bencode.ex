defmodule Bencode do
  defmodule Spec do
    import Parser
    alias Parser.Number

    def term(s) do
      int(s) <|> string(s) <|> list(s) <|> dict(s)
    end

    def int(s) do
      with {:ok, _, s} <- char(s, "i"),
           {:ok, x, s} <- Number.signed(s),
           {:ok, _, s} <- char(s, "e") do
        {:ok, x, s}
      end
    end

    def string(s) do
      with {:ok, n, s} <- Number.unsigned(s),
           {:ok, _, s} <- char(s, ":"),
           {:ok, s, s} <- take(s, n) do
        {:ok, s, s}
      end
    end

    def list(s) do
      with {:ok, _, s} <- char(s, "l"),
           {:ok, x, s} <- many(s, &term/1),
           {:ok, _, s} <- char(s, "e") do
        {:ok, x, s}
      end
    end

    def dict(s) do
      with {:ok, _, s} <- char(s, "d"),
           {:ok, x, s} <- many(s, &pair/1),
           {:ok, _, s} <- char(s, "e") do
        {:ok, x |> Enum.into(Map.new()), s}
      end
    end

    defp pair(s) do
      with {:ok, k, s} <- term(s),
           {:ok, v, s} <- term(s) do
        {:ok, {k, v}, s}
      end
    end
  end

  def decode(source) do
    Parser.run(Spec, :term, source)
  end
end
