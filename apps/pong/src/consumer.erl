-module (consumer).

-export ([consume_with_reply/2, loop/2]).

consume_with_reply(Connection, Queue) ->
  lists:map(fun(_) ->
    Channel = bunny_client:open_channel(Connection),
    Pid = spawn(?MODULE, loop, [Channel, Queue]),
    bunny_client:subscribe(Channel, Queue, Pid),
    Pid
  end, lists:seq(0, 5)).

loop(Channel, Queue) ->
  bunny_client:consume_msg(Channel, Queue),
  timer:sleep(2000),
  db:increment(),
  io:format("[producing] PONG_MESSAGE to pong queue~n"),
  bunny_client:produce(Channel, <<"pong">>, <<"PONG_MESSAGE">>),
  loop(Channel, Queue).
