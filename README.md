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

You earn points by tossing 5s and 10s, and by tossing certain
combinations of symbols. I'm gonna leave it there for now - hopefully
you'll pick up the rest as we go along.

## A Note On Terminology

In Cosmic Wimpout, you don't "roll the dice," you "toss the cubes."
I'm not going to say it again. Just accept it. (But don't feel bad if you
slip up - I just finished searching the code, replacing all references to
'roll', 'die', and 'dice'.)

## Breaking Down the Rules

I'll try to build the game in steps, so as to not go crazy, and so
I have something playable all along the way.

0. _Create a game, with named players, who have points. Cycle through
   their turns, and collect points from each turn._ **DONE**
1. _Start throwing cubes. Each turn, the player throws all 5 cubes, and
   gets points for any numbered cubes. End of turn, bank your points._
   **DONE**
2. _If you toss the cubes, and some come up symbols, you can choose to
   re-toss the symbol cubes for more points, or bank this turn's points. If you
   ever throw **all** symbols, your turn ends, and you lose this turn's
   points (a "cosmic wimpout!"). Once you're out of cubes, your turn
   ends - bank any points you earned._ **DONE**
3. _Don't let Players with zero banked points end their turn until they
   have 35 or more points for the turn._ **DONE**
4. _"You may not want to, but you must." If you've scored on all 5
   cubes, throw all 5 cubes again, and keep gathering points._ **DONE**
5. End-game scenario: once one Player gets 500 points (or 300 -
   parameterize), end the game. (Add the "Last Licks" rule later.)
6. FLASH. If you toss three-of-a-kind, either numbers or symbols,
   you get 10x that many points added to your turn. Examples:
   * If you toss [5, 10, six, six, six], earn 5 + 10 + (6 * 10) = 75 points.
   * If you toss [10, 10, 10, six, 5], earn 5 + (10 * 10) = 105 points.
7. Clear the Flash. If you toss a flash, toss the remaining
   unscored cubes (or, if you scored on all of them, toss all 5), until
   they all come up different from the value you flashed.
   * If you tossed [5, 5, 5, two, three], you get 50 points, but you have
     to toss the other two cubes until neither comes up 5.
   * If you tossed [5, 5, four, four, four], you get 40 + 5 + 5 = 50 points,
     but you have to toss ALL FIVE CUBES until none comes up four.

That's far enough for right now.

## OH WAIT, YOU WANT TO ACTUALLY PLAY IT?

Now you can. Load icw.rb in irb, construct an IrbGame
with the names of your players, and start sharing the keyboard.

```
dan@prodigal:~/projects/cosmicwimpout$ irb
ruby-1.9.2-p180 :001 > load 'icw.rb' # That's Interactive Cosmic Wimpout, kids.
 => true
ruby-1.9.2-p180 :002 > g = IrbGame.new 'Fred', 'Wilma'
 => #<IrbGame:0x8667b48 ...>
ruby-1.9.2-p180 :003 > g.take_turn
Fred has 0 points
Wilma has 0 points
Fred's turn.
Tossed: four, three, three, six, Black four
 => nil
 (some boring turns removed...)
ruby-1.9.2-p180 :006 > g.take_turn
Wilma has 0 points
Fred has 0 points
Wilma's turn.
Tossed: 10, 5, six, 10, Black six
Tossed: three, Black 10
Wilma earned 35 this turn!
 => nil
ruby-1.9.2-p180 :007 > g.take_turn
Fred has 0 points
Wilma has 35 points
Fred's turn.
Tossed: six, four, 10, 5, Black 5
Tossed: two, two
 => nil
ruby-1.9.2-p180 :008 > g.take_turn
Wilma has 35 points
Fred has 0 points
Wilma's turn.
Tossed: two, six, 10, two, Black 5

> Wilma, you have 15 points so far this turn.
> Do you want to toss these cubes?
> two, six, two
> Toss 'em? (y, n) y
Tossed: three, 10, 5

> Wilma, you have 30 points so far this turn.
> Do you want to toss these cubes?
> three
> Toss 'em? (y, n) n
Wilma earned 30 this turn!
 => nil

```
