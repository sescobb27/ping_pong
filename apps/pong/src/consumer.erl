-module (consumer).

-export ([consume_with_reply/2, loop/2, create_consumers/3]).

consume_with_reply(Connection, Queue) ->
  Channel = bunny_client:open_channel(Connection),
  Pid = spawn_link(?MODULE, loop, [Channel, Queue]),
  bunny_client:subscribe(Channel, Queue, Pid),
  Pid.

create_consumers(N, Connection, Queue) ->
  lists:map(fun(_) ->
    consume_with_reply(Connection, Queue)
  end, lists:seq(0, N)).

loop(Channel, Queue) ->
  bunny_client:consume_msg(Channel, Queue),
  db:increment(),
  io:format("[producing] PONG_MESSAGE to pong queue~n"),
  bunny_client:produce(Channel, <<"pong">>, <<"PONG_MESSAGE">>),
  loop(Channel, Queue).
