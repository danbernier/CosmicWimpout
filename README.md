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

0. **DONE** _Create a game, with named players, who have points. Cycle through
   their turns, and collect points from each turn._
1. **DONE** _Start throwing cubes. Each turn, the player throws all 5 cubes, and
   gets points for any numbered cubes. End of turn, bank your points._
2. **DONE** _If you toss the cubes, and some come up symbols, you can choose to
   re-toss the symbol cubes for more points, or bank this turn's points. If you
   ever throw **all** symbols, your turn ends, and you lose this turn's
   points (a "cosmic wimpout!"). Once you're out of cubes, your turn
   ends - bank any points you earned._
3. **DONE** _Don't let Players with zero banked points end their turn until they
   have 35 or more points for the turn._
4. **DONE** _**You may not want to, but you must.** If you've scored on all 5
   cubes, throw all 5 cubes again, and keep gathering points._
5. End-game: once one Player gets 500 points (or 300 - parameterize), end the 
   game.
6. **Last Licks** When one Player gets 500 (or 300) points, yes, end the game -
   but first, every other player gets one last turn. Only after the rest of the
   players earn their last-licks points, can you determine who has the most
   points, and is the winner.
7. **The Flaming Sun** if the black cube comes up with the sun, you can count
   it as whatever you like.
8. **Flash** If you toss three-of-a-kind, either numbers or symbols,
   you get 10x that many points added to your turn. Examples:
   * If you toss [5, 10, six, six, six], earn 5 + 10 + (6 * 10) = 75 points.
   * If you toss [10, 10, 10, six, 5], earn 5 + (10 * 10) = 105 points.
9. **Clear the Flash** If you toss a flash, toss the remaining
   unscored cubes (or, if you scored on all of them, toss all 5), until
   they all come up different from the value you flashed.
   * If you tossed [5, 5, 5, two, three], you get 50 points, but you have
     to toss the other two cubes until neither comes up 5.
   * If you tossed [5, 5, four, four, four], you get 40 + 5 + 5 = 50 points,
     but you have to toss ALL FIVE CUBES until none comes up four.
10. **The Flaming Sun Rule** if you toss two-of-a-kind and a Flaming Sun, you MUST
   count the sun as whatever the two-of-a-kind was of, to complete the flash.
   Examples:
   * If you toss [sun, two, six, 5, four], count the sun as whatever you want.
   * If you toss [sun, two, two, 5, four], the sun MUST be a two.
11. **Freight Train** If you toss 5 matching faces (all twos, all fours, etc),
   you earn 100 times the face-value! Five twos = 200, Five fours = 400, etc.
12. **INSTANT WINNER** If you toss 5 sixes, you win the game! Instantly! No Last
   Licks or anything!
13. **Super-Nova** If you toss 5 10s, that is just Too Many Points. You are
   instantly out of the game.

## OH WAIT, YOU WANT TO ACTUALLY PLAY IT?

Now you can. Load icw.rb in irb, construct an IrbGame
with the names of your players, and start sharing the keyboard.

```
dan@prodigal:~/projects/cosmicwimpout$ irb
ruby-1.9.2-p180 :001 > load 'icw.rb' # That's Interactive Cosmic Wimpout, kids.
 => true
ruby-1.9.2-p180 :002 > g = start 'Fred', 'Wilma'
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
