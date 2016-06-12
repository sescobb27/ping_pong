-module (pong_handler).
-export ([init/0, loop/1]).

init() ->
  process_flag(trap_exit, true),
  Worker = poolboy:checkout(bunny_pong_pool, true, infinity),
  Connection = bunny_worker:get_connection(Worker),
  consumer:create_consumers(255, Connection, <<"ping">>),
  spawn(?MODULE, loop, [Connection]).

loop(Connection) ->
  receive
    {'EXIT', FromPid, Reason} ->
      io:format("[EXIT] process (~w) died because(~w)~n", FromPid, Reason),
      consumer:consume_with_reply(Connection,  <<"ping">>),
      loop(Connection)
  end.
