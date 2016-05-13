-module (pong_handler).
-export ([init/0]).

init() ->
  Worker = poolboy:checkout(bunny_pool, true, infinity),
  Connection = gen_server:call(Worker, get_connection),
  consumer:consume_with_reply(Connection, <<"ping">>).
