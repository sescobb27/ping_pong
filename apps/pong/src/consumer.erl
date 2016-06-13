-module (consumer).

-export ([consume_with_reply/2, loop/2]).

consume_with_reply(Connection, Queue) ->
  Channel = bunny_client:open_channel(Connection),
  Pid = spawn_link(?MODULE, loop, [Channel, Queue]),
  bunny_client:subscribe(Channel, Queue, Pid),
  {ok, Pid}.

loop(Channel, Queue) ->
  bunny_client:consume_msg(Channel, Queue),
  db:increment(),
  io:format("[producing] PONG_MESSAGE to pong queue~n"),
  bunny_client:produce(Channel, <<"pong">>, <<"PONG_MESSAGE">>),
  loop(Channel, Queue).
