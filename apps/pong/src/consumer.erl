-module (consumer).

-export ([consume_with_reply/2, loop/2]).

consume_with_reply(Connection, Queue) ->
  Channel = bunny_client:open_channel(Connection),
  Pid = spawn_link(?MODULE, loop, [Channel, Queue]),
  bunny_client:subscribe(Channel, Queue, Pid),
  {ok, Pid}.

loop(Channel, Queue) ->
  BinaryMsg = bunny_client:consume_msg(Channel, Queue),
  Msg = binary_to_term(BinaryMsg),
  Key = maps:get(key, Msg),
  PongMsg = #{
    key => Key,
    msg => <<"PONG_MESSAGE">>
  },
  db:increment(),
  io:format("[producing] PONG_MESSAGE to pong queue~n"),
  BinaryPongMsg = term_to_binary(PongMsg),
  bunny_client:produce(Channel, <<"pong">>, BinaryPongMsg),
  loop(Channel, Queue).
