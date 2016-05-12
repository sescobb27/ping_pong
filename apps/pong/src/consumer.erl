-module (consumer).

-export ([consume_with_reply/3, loop/3]).

-include_lib("amqp_client/include/amqp_client.hrl").

consume_with_reply(PingChannel, PongChannel, Queue) ->
  Pid = spawn(?MODULE, loop, [PingChannel, PongChannel, Queue]),
  bunny_client:subscribe(PingChannel, Queue, Pid),
  {ok, Pid}.

loop(PingChannel, PongChannel, Queue) ->
  bunny_client:consume_msg(PingChannel, Queue),
  timer:sleep(2000),
  db:increment(),
  io:format("[producing] PONG_MESSAGE to pong queue~n"),
  bunny_client:produce(PongChannel, <<"pong">>, <<"PONG_MESSAGE">>),
  loop(PingChannel, PongChannel, Queue).
