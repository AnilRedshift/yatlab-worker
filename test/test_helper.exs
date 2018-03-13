require Mox

Application.ensure_all_started(:mox)
Mox.defmock(Worker.DatabaseApi.MockClient, for: Worker.DatabaseApi)
Mox.defmock(Worker.SlackWebApi.Channels.MockClient, for: Worker.SlackWebApi.Channels)
Mox.defmock(Worker.SlackWebApi.Chat.MockClient, for: Worker.SlackWebApi.Chat)
Mox.defmock(Worker.SlackWebApi.Groups.MockClient, for: Worker.SlackWebApi.Groups)
Mox.defmock(Worker.SlackWebApi.Im.MockClient, for: Worker.SlackWebApi.Im)
Mox.defmock(Worker.SlackWebApi.Reactions.MockClient, for: Worker.SlackWebApi.Reactions)
ExUnit.start()
