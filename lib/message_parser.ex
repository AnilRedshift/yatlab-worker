defmodule Worker.MessageParser do
  alias Worker.Database.Acronym
  def parse(text, acronyms) do
    Enum.filter(acronyms, fn %Acronym{name: name} ->
      name = Regex.escape(name)
      {:ok, re} = Regex.compile("\\b#{name}(?:s|'s)?\\b", "i")
      Regex.match?(re, text)
    end)
  end
end
