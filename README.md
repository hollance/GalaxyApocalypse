# GALAXY APOCALYPSE

This is my January 2013 game for [One Game a Month](http://www.onegameamonth.com).

![Screenshot](https://github.com/hollance/GalaxyApocalypse/raw/master/Screenshot.png)

[Watch a video of the game in action (YouTube)](http://www.youtube.com/watch?v=5err_uBisYo)

## The game rules

The galaxy is falling apart! To save it, you have to move the planets back to where they belong!

Every so often portals appear on the screen. Your job is to swipe the planets into a portal of the matching color.

The portals lose power over time. Matching a planet with the wrong portal will drain even more power from the portal. If a portal has no more power it collapses and takes the entire universe with it! You don’t want that to happen on your watch…

Moons (the grey things) can be matched with any portal. A white portal accepts any type of planet. The only thing you should never send through any portal is a black hole (obviously).

Now go save the galaxy!

## One Game a Month

[One Game a Month](http://www.onegameamonth.com) is a challenge to make twelve games in one year, roughly one per month.

I've done similar challenges in the past, such as composing at least one piece of piano music or coming up with at least one app idea each day for 30 days in a row. It's a lot of work but it also pushes your creativity to higher levels.

When you limit yourself to making a game in a very short time, by necessity you have to limit the scope of the game. Such constraints can be quite inspirational. How small can you make a game that is still interesting?

My most successful game, _Ultimate Countdown_ (now removed from the App Store), was done in a single weekend as a similar kind of challenge. It ended up being downloaded over 250,000 times, which I found quite impressive back in 2008, even for a free game.

So if you're into game development -- or if making games is something you've always dreamed of -- then head on over to [www.onegameamonth.com](http://www.onegameamonth.com) and sign up!

## Building the game

*Galaxy Apocalypse* was made using Objective-C and the Cocos2D and Box2D libraries, which are included as a git submodule. It requires at least iOS 5 and ARC.

After cloning the repo, do this from Terminal to pull in the Cocos2D source code and switch it to the stable v2.0 branch:

    $ cd to_where_you_cloned_the_repo
    $ git submodule update --init
    $ cd Source/External/Cocos2D
    $ git checkout release-2.0

Then open `Game.xcodeproj` into Xcode and build the "Game" target.

You may want to set the `COCOS2D_DEBUG` flag in the "cocos2d" target to 0 (instead of 2) to reduce the amount of debug output from Cocos2D, which slows down the game a lot.

I also included the Photoshop files for the artwork (CS6) and the individual sprite images. The sprite sheets were made using TexturePacker, the fonts using Glyph Designer.

## What next?

The game took five days to make from scratch to finish. If I had more time I would polish it more and put it on the App Store. In its current shape the game is OK but needs more work to stand out.

Some ideas:

- The game play could use some balancing. Difficulty should improve more consistently; sometimes the game feels much harder than other times (too random). Especially having two or three portals at the same time makes it become very hard very quickly.
- Draw a trail of particles where you are swiping.
- One really big planet, occurs only every so often.
- Comet storm: small comets fly into the screen at a random angle and add additional impulse to all planets.
- Bonus points for catching the space man / alien.
- Game Center leaderboards for high scores.
- Maybe you can still "pull out" a planet that goes into the wrong portal, but it is a lot heavier while it is colliding with the portal.

Known issues:

- The text is sometimes blurry. I blame Cocos2D for this. ;-)

## Credits

Most of the imagery was based on NASA photographs from [www.jpl.nasa.gov](http://www.jpl.nasa.gov).

Intro music: *Lightless Dawn* by Kevin MacLeod ([incompetech.com](http://incompetech.com)).

Game music: *Trial By Fire* by Matt McFarland ([www.mattmcfarland.com](http://www.mattmcfarland.com)).

Explosion animation by [WrathGames Studio](http://opengameart.org/content/wgstudio-explosion-animation).

Sound effects from [freesound.org](http://freesound.org) and [opengameart.org](http://opengameart.org). Because I was in a hurry when I made this game, I didn't pay much attention to the licensing on the sound effects. They are OK for non-commercial use but may not all be cleared for commercial use.

## License

Source code is copyright (C) 2013 M.I. Hollemans

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
