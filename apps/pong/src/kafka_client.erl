-module (kafka_client).
-export ([init/1, init_producer/2, produce/3]).

-spec init(atom()) -> pid().
init(Client) ->
  {ok, KafkaPort} = application:get_env(pong, kafka_pong_client),
  {ok, _ClientPid} = brod:start_link_client([{"localhost", KafkaPort}], Client, []).

-spec init_producer(atom(), binary()) -> {ok, pid()} | {error, Reason}
      when Reason :: client_down
                   | {producer_down, noproc}
                   | {producer_not_found, brod:topic()}
                   | {producer_not_found, brod:topic(), brod:partition()}.
init_producer(Client, Topic) ->
  brod:start_producer(Client, Topic, []).

-spec produce(atom(), binary(), binary()) -> ok | {error, any()}.
produce(Client, Topic, Value) ->
  brod:produce_sync(Client, Topic, 0, <<"">>, Value).
