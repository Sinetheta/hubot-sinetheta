# Description:
#   Jenkins notifications via webhook
#
# URLS:
#   POST /hubot/jenkins?room=<room_name>

USERNAME      = process.env.HUBOT_JENKINS_USERNAME      || "jenkins"
USER_EMOJI    = process.env.HUBOT_JENKINS_USER_EMOJI
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
      icon_emoji: USER_EMOJI
      attachments: [
        title: "#{data.name} build ##{data.build.number}"
        title_link: data.build.full_url
      ]

    robot.adapter.customMessage payload
