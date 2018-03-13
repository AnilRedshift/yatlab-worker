require Mox
Mox.defmock(Worker.DatabaseApi.MockClient, for: Worker.DatabaseApi)
Mox.defmock(Worker.SlackWebApi.Chat.MockClient, for: Worker.SlackWebApi.Chat)
Mox.defmock(Worker.SlackWebApi.Im.MockClient, for: Worker.SlackWebApi.Im)
Mox.defmock(Worker.SlackWebApi.Reactions.MockClient, for: Worker.SlackWebApi.Reactions)
ExUnit.start()
