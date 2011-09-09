# Cosmic Wimpout

[Cosmic Wimpout](http://en.wikipedia.org/wiki/Cosmic_Wimpout) is a
dice game with pretty crazy rules.

I'm going to try to build Cosmic Wimpout in Ruby, as part of the [Ruby
Mendicant University](http://university.rubymendicant.com) September
2011 session.

## Cosmic Wimpout, As She is Played (sort of)

Basically, people sit in a circle, and throw dice in turns. Each turn,
a player earns some points, and adds them to his running total. Once 
one of the players reaches the goal, game's over.

There are five dice: four white, one black. The white dice have two 
numeric sides - 5 and 10 - and four symbolic sides - two, three, four,
and six. The black die is the same, but instead of a three, it has a
sun (a wildcard).

You earn points by rolling 5s and 10s, and by rolling certain 
combinations of symbols. I'm gonna leave it there for now - hopefully
you'll pick up the rest as we go along.

## Breaking Down the Rules

I'll try to build the game in steps, so as to not go crazy, and so
I have something playable all along the way.

0. Create a game, with named players, who have points. Cycle through 
   their turns, and collect points from each turn.
1. Start throwing dice. Each turn, the player throws all 5 dice, and 
   gets points for any numbered dice. End of turn, bank your points.
2. Let the player re-throw any dice that came up symbols. If you ever
   throw __all__ symbols, your turn ends (a "cosmic wimpout!"). Once 
   you're out of dice, your turn ends. Bank any points you earned.
3. "You may not want to, but you must." If you've scored on all 5 
   dice, throw all 5 dice again, and keep gathering points.
4. End-game scenario: once one Player gets 500 points (or 300 -
   parameterize), end the game. (Add the "Last Licks" rule later.)

That's far enough for right now. We'll get to THE FLASH soon enough.
    
   
