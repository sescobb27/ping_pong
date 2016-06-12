-module (ping_handler).
-export ([init/3, terminate/3, handle/2]).

init(_Type, Req, []) ->
  {ok, Req, []}.

handle(Req, State) ->
  poolboy:transaction(bunny_ping_pool, fun (Worker) ->
    io:format("[producing] PING_MESSAGE to ping queue~n"),
    Connection = bunny_worker:get_connection(Worker),
    Channel = bunny_client:open_channel(Connection),
    bunny_client:produce(Channel, <<"ping">>, <<"PING_MESSAGE">>),
    bunny_client:subscribe(Channel, <<"pong">>, self()),
    bunny_client:consume_msg(Channel, <<"pong">>),
    bunny_client:close_channel(Channel)
  end, infinity),
  {ok, Req, State}.

terminate(_Reason, _Req, _State) ->
  ok.
