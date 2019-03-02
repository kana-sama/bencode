defmodule Parser.Number do
  import Parser

  def signed(s) do
    with {:ok, sign, s} <- sign(s),
         {:ok, number, s} <- unsigned(s) do
      {:ok, sign * number, s}
    end
  end

  defp sign(s) do
    with {:ok, sign, s} <- optional(s, &char(&1, ?-)) do
      sign =
        case sign do
          {:some, _char} -> -1
          :none -> 1
        end

      {:ok, sign, s}
    end
  end

  def unsigned(s) do
    do_number(s, [])
  end

  defguardp is_digit(code) when code >= 48 and code <= 57

  defp do_number(<<digit, s::binary>>, digits) when is_digit(digit) do
    do_number(s, [digit - 48 | digits])
  end

  defp do_number(s, []) do
    {:error, %{rest: s}}
  end

  defp do_number(s, digits) do
    number = List.foldr(digits, 0, fn digit, number -> number * 10 + digit end)
    {:ok, number, s}
  end
end
