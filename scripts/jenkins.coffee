# Description:
#   Jenkins notifications via webhook
#
# URLS:
#   POST /hubot/jenkins?room=<room_name>

USERNAME      = process.env.HUBOT_JENKINS_USERNAME      || "jenkins"
module.exports = (robot) ->
  robot.router.post "/#{robot.name}/jenkins", (req, res) ->
    room = req.query.room
    data = req.body

    unless room?
      return res.status(400).send("Bad Request").end()

    res.status(202).end()

    return unless data.build.phase is "FINALIZED"

    payload =
      channel: "#{room}"
      username: USERNAME

    robot.adapter.customMessage payload
