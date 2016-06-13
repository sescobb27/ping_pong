-module (pong_subscriber_sup).
-export ([init/1, start_link/1]).

-behaviour(supervisor).

start_link(Num) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Num]).

init([Num]) ->
  Worker = poolboy:checkout(bunny_pong_pool, true, infinity),
  Connection = bunny_worker:get_connection(Worker),
  Children = lists:map(fun(Seq) ->
    #{
      id => "consumer_" ++ integer_to_list(Seq),
      start => {consumer, consume_with_reply, [Connection, <<"ping">>]},
      restart => transient,
      shutdown => brutal_kill
    }
  end, lists:seq(0, Num)),
  io:format("~p~n", [Children]),
  {ok, { {one_for_one, 10, 60}, Children}}.
