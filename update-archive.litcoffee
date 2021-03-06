
# Update the local data archive

This short script simply starts up an instance of the Archivist module.
See [that module's documentation](archivist.litcoffee) for details of what
that module does when started.

First, create the API access tools.  Note that you need your Vainglory API
key as an environment variable visible to this script when it runs.

    vainglory = require 'vainglory'
    key = process.env.VG_API_KEY

Import the Archivist module and set some parameters.  Hand it the
`vainglory` object just created, so it can make queries using my API key.

    archivist = require './archivist'
    archivist.setStartTime new Date 2017, 2, 29, 16
    archivist.setEndTime new Date 2017, 3, 1, 12
    archivist.setMaxima ranked : 5 # everything else zero
    archivist.setQueryFrequency 7*archivist.seconds
    archivist.setQueryObject new vainglory key
    archivist.setMatchArchiveFolder 'archive'
    require './harvesters'
    .installInto archivist

Now I want to choose the value for `setDuration` based on having a priori
chosen how many matches I want in my archive.  This is not necessary for
every use of the `archivist` module; it's just what I want to do here.  So
I choose this value:

    getThisManyMatches = 3000
    archivist.setMetaData 'number of matches', getThisManyMatches

Now I compute all this stuff to figure out what value to pass to
`setDuration`, and doing so then completes the archivist setup process.

    numberEachInterval = 0
    for own gameMode, count of archivist.getMaxima()
        numberEachInterval += count
    numberOfIntervals = getThisManyMatches / numberEachInterval
    totalDuration = archivist.getEndTime() - archivist.getStartTime()
    archivist.setDuration totalDuration / numberOfIntervals

Start the archive-updating process.

    process.on 'unhandledRejection', ( err ) -> console.log err
    startedAt = new Date
    startedWithArchiveAt = archivist.latestDateInArchive()
    startedWithArchiveAt ?= archivist.getStartTime()
    console.log 'Starting to update archive...'
    archivist.setDebugging on
    archivist.startAPIQueries ( progress ) ->
        progress ?= archivist.getStartTime()
        elapsed = ( new Date ) - startedAt
        completed = progress - startedWithArchiveAt
        toComplete = archivist.getEndTime() - startedWithArchiveAt
        estimatedTotalTime = if completed > 0
            elapsed * toComplete / completed
        else
            undefined
        percentDone = if toComplete > 0
            100 * completed / toComplete
        else
            undefined
        remainingString = if estimatedTotalTime
            left = ( estimatedTotalTime - elapsed ) / 60000
            "estimating #{Number( left ).toFixed 1}min left"
        else
            'no completion estimate available yet'
        console.log "Completed #{Number( percentDone ).toFixed 1}% in
            #{Number( elapsed / 60000 ).toFixed 1}min,
            #{remainingString}"
