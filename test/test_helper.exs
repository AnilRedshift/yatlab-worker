require Mox
Mox.defmock(Worker.DatabaseApi.MockClient, for: Worker.DatabaseApi)
ExUnit.start()
