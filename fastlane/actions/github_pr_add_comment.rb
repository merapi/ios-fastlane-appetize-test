module Fastlane
  module Actions
    module SharedValues

    end

    class GithubPrAddCommentAction < Action
      def self.run(params)

        require 'json'
        require 'excon'

        params[:api_token] = ENV['GITHUB_API_TOKEN']
        token = ENV['GITHUB_API_TOKEN']
        repo = ENV['CIRCLE_PROJECT_USERNAME'] + '/' + ENV['CIRCLE_PROJECT_REPONAME']
        id = ENV['CI_PULL_REQUEST'].split('/')[-1]

        headers = { 'User-Agent' => 'fastlane-get_github_pr_labels' }
        headers['Authorization'] = "token #{token}" if token

        url = "https://api.github.com/repos/#{repo}/issues/#{id}/comments"

        data = {
            'body' => "new builds ready"
        }
        data['body'] = params[:body] if params[:body]

        #data['body'] = "comment body #{ENV['CI_PULL_REQUEST']}"
        response = Excon.post(url, headers: headers, body: data.to_json)

        if response[:status] == 201
          body = JSON.parse(response.body)
          number = body['number']
          html_url = body['html_url']
          UI.success("Successfully created pull request. You can see it at '#{html_url}'")

          Actions.lane_context[SharedValues::CREATE_PULL_REQUEST_HTML_URL] = html_url
        elsif response[:status] != 200
          UI.error("GitHub responded with #{response[:status]}: #{response[:body]}")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_GITHUB_PR_GET_LABELS_API_TOKEN", # The name of the environment variable
                                       description: "API Token for GithubPrGetLabelsAction", # a short description of this parameter
                                       default_value: false,
                                       verify_block: proc do |value|
                                          # UI.user_error!("No API token for GithubPrGetLabelsAction given, pass using `api_token: 'token'`") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :body,
                                       description: "Comment body",
                                       is_string: true,
                                       default_value: '')
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['GITHUB_PR_GET_LABELS_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["merapi"]
      end

      def self.is_supported?(platform)
        # you can do things like
        # 
        #  true
        # 
        #  platform == :ios
        # 
        #  [:ios, :mac].include?(platform)
        # 

        platform == :ios
      end
    end
  end
end
