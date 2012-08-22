# Description:
#   Find the build status of an open-source project on Travis
#   Can also notify about builds, just enable the webhook notification on travis http://about.travis-ci.org/docs/user/build-configuration/ -> 'Webhook notification'
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot travis me <user>/<repo> - Returns the build status of https://github.com/<user>/<repo>
#
# URLS:
#   POST /hubot/travis?room=<room>[&type=<type]
#
# Author:
#   sferik
#   nesQuick

url = require('url')
querystring = require('querystring')

module.exports = (robot) ->
  
  robot.respond /travis me (.*)/i, (msg) ->
    project = escape msg.match[1]
    msg.http("http://travis-ci.org/#{project}.json").get() (err, res, body) ->
        result = JSON.parse res.body
        msg.send "Build status for #{project}: Passing" if result.last_build_status is 0
        msg.send "Build status for #{project}: Failing" if result.last_build_status is 1
        msg.send "Build status for #{project}: Unknown" unless result.last_build_status in [0, 1]  

  robot.router.post "/hubot/travis", (req, res) ->
    query = querystring.parse url.parse(req.url).query
    res.end JSON.stringify {
       received: true #some client have problems with and empty response
    }

    user = {}
    user.room = query.room if query.room
    user.type = query.type if query.type

    payload = JSON.parse req.body.payload

    robot.send user, "#{payload.author_name} triggered build of #{payload.repository.name} and it #{payload.status_message}!"