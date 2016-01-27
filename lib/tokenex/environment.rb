require "json"
require "net/https"
require "uri"

module Tokenex
    class Environment
    
        def initialize(api_base_url, tokenex_id, api_key, options={})
            @api_base_url = api_base_url
            @tokenex_id = tokenex_id
            @api_key = api_key
        end
        
        def token_from_ccnum(ccNum)
            action = "Tokenize"
            data = {
                "Data" => ccNum,
                "TokenScheme" => 3
            }
            
            return send_request(action, data)
        end
        
        def ccnum_from_token(token)
            action = "Detokenize"
            data = {
                "Token" => token
            }
            
            return send_request(action, data)
        end
        
        private
        def headers
            {
                'Content-Type' => 'application/json',
                'Accept' => 'application/json'
            }
        end
        
        def build_request_array(data)
            request_array = {
                "APIKey" => @api_key,
                "TokenExID" => @tokenex_id
            }.merge(data)
             
            return request_array
        end

        def send_request(action, data)
            request_body = build_request_array(data).to_json
            
            uri = URI.parse("#{@api_base_url}#{action}")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            
            request = Net::HTTP::Post.new(uri, initheader = headers)
            request.body = request_body
            response = http.request(request)
            return JSON.parse(response.body)
        end

    end
end