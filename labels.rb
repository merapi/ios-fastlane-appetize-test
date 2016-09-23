#!/usr/bin/env ruby
require 'octokit'
require 'fastlane'

options = {
    api_token: 'someToken'
}
result = Fastlane::OneOff.run(action: "pocnative",
                          parameters: options)
puts result
exit

puts "Labels check"

# only for PRs
if ENV['CI_PULL_REQUEST'] == '' then
    exit
end

id = ENV['CI_PULL_REQUEST'].split('/')[-1]
repo = ENV['CIRCLE_PROJECT_USERNAME'] + '/' + ENV['CIRCLE_PROJECT_REPONAME']
#ENV['CIRCLE_REPOSITORY_URL']

p id
p repo

client = Octokit::Client.new :access_token => ENV['GITHUB_TOKEN']

# user = client.user
# puts user.login

# client.issue_comments(repo, id).each do |comment|
#   username = comment[:user][:login]
#   post_date = comment[:created_at]
#   content = comment[:body]

#   puts "#{username} made a comment on #{post_date}. It says:\n'#{content}'\n"
# end

# pr = client.issue(repo, id)
# p [pr.body, pr.title, pr.labels]

prl = client.labels_for_issue(repo, id)
p prl

p client.update_issue(repo, id, { :title => 'new title 4', :body => 'updated body 4' })

