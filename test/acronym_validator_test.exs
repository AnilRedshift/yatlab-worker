defmodule AcronymValidatorTest do
  use ExUnit.Case
  alias Worker.Database.Acronym

  @acronym %Acronym{
    added_by: "Anil Kulkarni",
    description: "he's a ham",
    id: 6,
    means: "Jordan",
    name: "HAM",
    team_id: "team1"
  }

  test "valid acronyms are not modified" do
    acronyms = [@acronym, create_acronym("FOO"), create_acronym("acronym with spaces")]
    assert AcronymValidator.validate(acronyms) == acronyms
  end

  test "An acronym with an empty string is removed" do
    acronyms = [@acronym, create_acronym("")]
    assert AcronymValidator.validate(acronyms) == [@acronym]
  end

  test "An acronym with just whitespace is removed" do
    acronyms = [@acronym, create_acronym("   ")]
    assert AcronymValidator.validate(acronyms) == [@acronym]
  end

  defp create_acronym(name), do: Map.put(@acronym, :name, name)
end
