-module (bunny_client).
-export ([init/1, produce/3, subscribe/3, close/1, consume_msg/2]).

-include_lib("amqp_client/include/amqp_client.hrl").

-spec init(binary()) -> pid().
init(Queue) ->
  {ok, Connection} = amqp_connection:start(#amqp_params_network{host = "localhost"}),
  {ok, Channel} = amqp_connection:open_channel(Connection),
  amqp_channel:call(Channel, #'queue.declare'{queue = Queue}),
  Channel.

-spec produce(atom(), binary(), binary()) -> ok | {error, any()}.
produce(Channel, Queue, Msg) ->
  amqp_channel:cast(Channel,
     #'basic.publish'{
       exchange = <<"">>,
       routing_key = Queue
     },
     #amqp_msg{payload = Msg}).

subscribe(Channel, Queue, Consumer) ->
  Sub = #'basic.consume'{queue = Queue},
  #'basic.consume_ok'{} = amqp_channel:subscribe(Channel, Sub, Consumer).

close(Channel) ->
  amqp_channel:close(Channel).

consume_msg(Channel, Queue) ->
  receive
      {#'basic.deliver'{delivery_tag = Tag}, #amqp_msg{payload = Body}} ->
          amqp_channel:cast(Channel, #'basic.ack'{delivery_tag = Tag}),
          io:format("[consuming] ~p from ~p queue~n", [Body, Queue])
  end.
