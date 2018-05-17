defmodule Worker.Stats do

  def log_typed_acronyms(acronyms: [], user_id: _), do: nil
  def log_typed_acronyms(acronyms: [acronym | acronyms], user_id: user_id) do
    Worker.Database.set_user_typed_acronym(acronym_id: acronym.id, user_id: user_id)
    log_typed_acronyms(acronyms: acronyms, user_id: user_id)
  end
end
