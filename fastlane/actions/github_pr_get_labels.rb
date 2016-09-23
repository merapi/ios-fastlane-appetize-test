module Fastlane
  module Actions
    module SharedValues
      GITHUB_PR_GET_LABELS_LIST = :GITHUB_PR_GET_LABELS_LIST
    end

    class GithubPrGetLabelsAction < Action
      def self.run(params)
        require 'json'
        require 'excon'

        params[:api_token] = ENV['GITHUB_API_TOKEN']
        token = ENV['GITHUB_API_TOKEN']
        repo = ENV['CIRCLE_PROJECT_USERNAME'] + '/' + ENV['CIRCLE_PROJECT_REPONAME']
        id = ENV['CI_PULL_REQUEST'].split('/')[-1]

        puts id
        puts repo

        headers = { 'User-Agent' => 'fastlane-get_github_pr_labels' }
        headers['Authorization'] = "token #{token}" if token

        middlewares = Excon.defaults[:middlewares] + [Excon::Middleware::RedirectFollower]
        #https://api.github.com/repos/merapi/ios-fastlane-appetize-test/issues/2/labels
        #https://api.github.com/repos/#{repo}/issues/#{id}/labels
        #url = "https://api.github.com/repos/#{repo}/issues/#{id}/labels?access_token=#{token}"
        url = "https://api.github.com/repos/#{repo}/issues/#{id}/labels"

        response = Excon.get(url, headers: headers, middlewares: middlewares)

        case response[:status]
        when 404
          UI.error("Repository #{repo} cannot be found, please double check its name and that you provided a valid API token (if it's a private repository).")
          return nil
        when 401
          UI.error("You are not authorized to access #{repo}, please make sure you provided a valid API token.")
          return nil
        else
          if response[:status] != 200
            UI.error("GitHub responded with #{response[:status]}:#{response[:body]}")
            return nil
          end
        end

        result = JSON.parse(response.body)

        UI.message(result)

        labels = []
        result.each do |label|
          labels.push(label['name'])
        end

        commit = Actions.last_git_commit_dict
        if commit[:message].include? '+appetize'
          labels.push('appetize') unless labels.include?('appetize')
        end
        if commit[:message].include? '+fabric'
          labels.push('fabric') unless labels.include?('fabric')
        end
        if commit[:message].include? '-appetize'
          labels.delete('appetize')
        end
        if commit[:message].include? '-fabric'
          labels.delete('fabric')
        end

        if commit[:message].include? ' +a'
          labels.push('appetize') unless labels.include?('appetize')
        end
        if commit[:message].include? ' +f'
          labels.push('fabric') unless labels.include?('fabric')
        end
        if commit[:message].include? ' -a'
          labels.delete('appetize')
        end
        if commit[:message].include? ' -f'
          labels.delete('fabric')
        end

        if commit[:message].include? ' +all'
          labels = ['appetize', 'fabric']
        end
        if commit[:message].include? ' -all'
          labels = []
        end

        Actions.lane_context[SharedValues::GITHUB_PR_GET_LABELS_LIST] = labels
        UI.message("Labels #{labels} 🚁")
        return labels
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
          FastlaneCore::ConfigItem.new(key: :development,
                                       env_name: "FL_GITHUB_PR_GET_LABELS_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one",
                                       is_string: false, # true: verifies the input is a string, false: every kind of value
                                       default_value: false) # the default value if the user didn't provide one
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
