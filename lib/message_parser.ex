defmodule Worker.MessageParser do
  alias Worker.Database.Acronym
  # https://stackoverflow.com/questions/6038061/regular-expression-to-find-urls-within-a-string
  @url_matcher ~r/(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$])/i
  def parse(text, acronyms) do
    text = strip_urls(text)

    Enum.filter(acronyms, fn %Acronym{name: name} ->
      name = Regex.escape(name)
      {:ok, re} = Regex.compile("\\b#{name}(?:s|'s)?\\b", "i")
      Regex.match?(re, text)
    end)
  end

  defp strip_urls(text) do
    Regex.replace(@url_matcher, text, "")
  end
end
