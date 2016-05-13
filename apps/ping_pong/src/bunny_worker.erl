-module (bunny_worker).

-behaviour(gen_server).
-behaviour(poolboy_worker).

-include_lib("amqp_client/include/amqp_client.hrl").

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).

-record(state, {rabbit_connection}).

start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

init(_Args) ->
    process_flag(trap_exit, true),
    {ok, Connection} = amqp_connection:start(#amqp_params_network{host = "localhost"}),
    {ok, #state{rabbit_connection=Connection}}.

handle_call(get_connection, _From, #state{rabbit_connection=Connection}=State) ->
    {reply, Connection, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{rabbit_connection=Connection}) ->
    amqp_connection:close(Connection).

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
