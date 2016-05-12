-module (ping_handler).
-export ([init/3, terminate/3, handle/2]).

-record (state, {
  pong_channel :: pid(),
  ping_channel :: pid()
}).

init(_Type, Req, []) ->
  PongChannel = bunny_client:init(<<"pong">>),
  PingChannel = bunny_client:init(<<"ping">>),
  State = #state{
    pong_channel = PongChannel,
    ping_channel = PingChannel
  },
  {ok, Req, State}.

handle(Req, State) ->
  io:format("[producing] PING_MESSAGE to ping queue~n"),
  bunny_client:produce(State#state.ping_channel, <<"ping">>, <<"PING_MESSAGE">>),
  bunny_client:subscribe(State#state.pong_channel, <<"pong">>, self()),
  bunny_client:consume_msg(State#state.pong_channel, <<"pong">>),
  bunny_client:close(State#state.ping_channel),
  bunny_client:close(State#state.pong_channel),
  {ok, Req, State}.

terminate(_Reason, _Req, _State) ->
  ok.
