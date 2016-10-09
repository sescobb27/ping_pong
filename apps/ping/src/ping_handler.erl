-module (ping_handler).
-export ([init/3, terminate/3, handle/2]).

init(_Type, Req, []) ->
  {ok, Req, []}.

handle(Req, State) ->
  retrial_ping(0),
  {ok, Req, State}.

retrial_ping(Times) ->
  retrial_ping(0, Times).

retrial_ping(Cont, Times) ->
  try
    exec_ping()
  catch
    exit:{timeout, Rest} ->
      case Cont < Times of
        true ->
          retrial_ping(Cont + 1, Times);
        _ ->
          erlang:exit({timeout, Rest})
      end
  end.

exec_ping() ->
  poolboy:transaction(bunny_ping_pool, fun (Worker) ->
    io:format("[producing] PING_MESSAGE to ping queue~n"),
    Connection = bunny_worker:get_connection(Worker),
    Channel = bunny_client:open_channel(Connection),
    Key = make_ref(),
    Msg = #{
      msg => <<"PING_MESSAGE">>,
      key => Key
    },
    BinaryMsg = term_to_binary(Msg),
    bunny_client:produce(Channel, <<"ping">>, BinaryMsg),
    bunny_client:subscribe(Channel, <<"pong">>),
    bunny_client:consume_msg(Channel, <<"pong">>, Key),
    bunny_client:close_channel(Channel)
  end).

terminate(_Reason, _Req, _State) ->
  ok.
