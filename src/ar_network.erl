-module(ar_network).
-export([start/1, start/2, start/3, start/4]).
-export([set_loss_probability/2, set_delay/2]).

%%% Manages virtual networks of gossip nodes.

%% Create a netwokr of Size ar_nodes, with Links connections each.
%% Defaults to creating a fully connected network.
start(Size) -> start(Size, Size).
start(Size, Connections) -> start(Size, Connections, 0).
start(Size, Connections, LossProb) ->
	start(Size, Connections, LossProb, 0).
start(Size, Connections, LossProb, MaxDelay) ->
	B0 = ar_weave:init(),
	Nodes = [ ar_node:start([], B0) || _ <- lists:seq(1, Size) ],
	lists:foreach(
		fun(Node) ->
			ar_node:add_peers(
				Node,
				ar_gossip:pick_random_peers(Nodes, Connections)
			),
			ar_node:set_loss_probability(Node, LossProb),
			ar_node:set_delay(Node, MaxDelay)
		end,
		Nodes
	),
	Nodes.

%% Change the likelihood of experiencing simulated network packet loss
%% for an entire network.
set_loss_probability(Net, Prob) ->
	lists:map(
		fun(Node) -> ar_node:set_loss_probability(Node, Prob) end,
		Net
	),
	ok.

%% Change the maximum delay time for a network.
set_delay(Net, MaxDelay) ->
	lists:map(
		fun(Node) -> ar_node:set_delay(Node, MaxDelay) end,
		Net
	),
	ok.
