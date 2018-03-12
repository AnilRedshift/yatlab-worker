defmodule Worker.Database do
   @database_api Application.get_env(:worker, :database_api)

   def call(team_id) do
     @database_api.get_acronyms(team_id)
   end
end
