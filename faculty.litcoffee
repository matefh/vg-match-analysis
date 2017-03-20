
# Faculty

## Purpose

The professors that will be teaching you how to play Vainglory live here.
Each is, unfortunately, a robot.  But they'll be as personable as they can.

This file collects together all the professors defined in various other
files in this repository, so that this module can use them to analyze a
match and produce advice data to show to players.  In fact, we provide a
function to do just that.  But first, let's load the modules that contain
the professors we'll use.

    faculty = ( require "./faculty/#{name}" for name in [
        'petal'
        'krul'
    ] )

All of theses modules appear in [the faculty folder](./faculty/).

## Main functions

Get all advice from all faculty and return it as an array of objects.  Each
must contain these fields:

 * `prof` - the name of the professor giving the advice (this will be a
   Vainglory hero, probably with a silly title attached, like
   "Professor Krul," etc.) (string)
 * `quote` - a quote from the hero that fits the topic they're teaching
   (string)
 * `topic` - a more standard description of what the hero is teaching
   (string)
 * `short` - a brief heading summarizing the advice returned (string)
 * `long` - a few sentences containing the advice (string)
 * `data` - this is the only optional field, and may contain arbitrary
   additional data that the UI may know how to render to show data about
   the advice, such as a table, pie chart, etc.

The match passed in must already have had its telemetry data fetched and
embedded in it.

We run all harvesters on this match and store the results in a single object
for use by all professors.

    exports.getAllAdvice = ( match, participant ) ->

We run all harvesters on this match and store the results in a single object
for use by all professors.

        harvesters = require './harvesters'
        matchData = harvesters.pick match, participant

We load the archive for matches of this type and store the results in a
single object for use by all professors.

        archivist = require './archivist'
        #
        # THE NEXT LINE IS WRONG!
        # JUST HERE FOR TESTING!
        # FIX THIS BEFORE COMMITTING!
        #
        gameMode = 'ranked' # archivist.simplifyType match.gameMode
        archive = archivist.allArchiveResults gameMode

Now ask each professor for advice.

        for professor, i in faculty
            professor.advice match, participant, matchData, archive