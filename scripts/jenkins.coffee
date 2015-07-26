# Description:
#   Jenkins notifications via webhook
#
# URLS:
#   POST /hubot/jenkins?room=<room_name>

module.exports = (robot) ->
  robot.router.post "/#{robot.name}/jenkins", (req, res) ->
    room = req.query.room

    unless room?
      return res.status(400).send("Bad Request").end()

    res.status(202).end()
