# Description:
#   Jenkins notifications via webhook
#
# URLS:
#   POST /hubot/jenkins?room=<room_name>

USERNAME      = process.env.HUBOT_JENKINS_USERNAME      || "jenkins"
USER_EMOJI    = process.env.HUBOT_JENKINS_USER_EMOJI
COLOR_FAILURE = process.env.HUBOT_JENKINS_COLOR_FAILURE || "#E74C3C"
COLOR_SUCCESS = process.env.HUBOT_JENKINS_COLOR_SUCCESS || "#2ECC71"

module.exports = (robot) ->
  robot.router.post "/#{robot.name}/jenkins", (req, res) ->
    room = req.query.room
    data = req.body

    unless room?
      return res.status(400).send("Bad Request").end()

    res.status(202).end()

    return unless data.build.phase is "FINALIZED"

    was_success = data.build.status is "FIXED" or data.build.status is "SUCCESS"
    color = if was_success then COLOR_SUCCESS else COLOR_FAILURE
    fields = []

    payload =
      channel: "#{room}"
      username: USERNAME
      icon_emoji: USER_EMOJI
      attachments: [
        title: "#{data.name} build ##{data.build.number}"
        title_link: data.build.full_url
        color: color
        fields: fields
      ]

    sha = data.build.scm.commit.slice(0,8)
    commit_url = "#{data.build.scm.url}/commit/#{sha}"
    text = "<#{commit_url}|#{data.build.scm.branch}##{sha}>"

    staged_url = data.build.parameters.URL
    if staged_url? and was_success
      text += "\n#{staged_url}"

    fields.push
      title: "Status"
      value: data.build.status
      short: true

    job_url = data.build.parameters.DOWNSTREAM
    if job_url? and was_success
      trigger_downstream = "#{job_url}/parambuild?GIT_COMMIT=#{data.build.scm.commit}"
      fields.push
        title: "Deploy Now"
        value: "<#{trigger_downstream}|trigger upstream build>"
        short: true

    payload.attachments[0].text = text

    robot.adapter.customMessage payload
