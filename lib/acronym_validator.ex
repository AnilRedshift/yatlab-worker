defmodule AcronymValidator do
  def validate(acronyms), do: reject_empty_names(acronyms)

  defp reject_empty_names(acronyms) do
    Enum.reject(acronyms, &String.match?(&1.name, ~r/^(\s*)$/))
  end
end
