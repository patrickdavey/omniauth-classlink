require 'omniauth-oauth2'
require 'base64'

module OmniAuth
  module Strategies
    class ClassLink < OmniAuth::Strategies::OAuth2
      option :name, :classlink
      option :client_options, {
        site:          'https://launchpad.classlink.com',
        authorize_url: '/oauth2/v2/auth',
        token_url:     '/oauth2/v2/token'
      }
      uid { raw_info["UserId"] }

      def authorize_params
        super.tap do |params|
          params[:scope] = [:email, :profile]
          params[:response_type] = :code
        end
      end

      info do
        {
          first_name: raw_info['FirstName'],
          last_name: raw_info['LastName'],
          district_id: raw_info['TenantId'],
          classlink_id: raw_info['UserId'],
          external_id: raw_info['SourcedId'],
          role: raw_info['Role']
        }
      end

      extra do
        { 'raw_info' => raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get('https://nodeapi.classlink.com/v2/my/info').parsed
      end


      private

      def callback_url
        request.params['redirect_uri'] || options[:redirect_uri] || super
      end
    end
  end
end
