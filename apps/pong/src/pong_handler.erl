-module (pong_handler).
-export ([init/0]).

init() ->
  PongChannel = bunny_client:init(<<"pong">>),
  PingChannel = bunny_client:init(<<"ping">>),
  consumer:consume_with_reply(PingChannel, PongChannel, <<"ping">>).
