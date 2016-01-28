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
            catch (:tokenex_cannot_tokenize_data) do
                return tokenize(ccNum, 3)
            end
            throw :tokenex_invalid_ccnum
        end
        
        def tokenize(data_to_tokenize, token_scheme = 4)
            action = "Tokenize"
            data = {
                "Data" => data_to_tokenize,
                "TokenScheme" => token_scheme
            }
            
            response = send_request(action, data)
            throw :tokenex_cannot_tokenize_data unless is_valid_response(response)
            
            return response['Token']
        end
        
        def detokenize(token)
            action = "Detokenize"
            data = {
                "Token" => token
            }
            
            response = send_request(action, data)
            throw :tokenex_invalid_token unless is_valid_response(response) 
            
            return response['Value']
        end
        
        def validate_token(token)
            action = "ValidateToken"
            data = {
                "Token" => token
            }
            
            response = send_request(action, data)
            throw :tokenex_invalid_token unless is_valid_response(response) 
            
            return response['Valid']
        end
        
        def delete_token(token)
            action = "DeleteToken"
            data = {
                "Token" => token
            }
            
            response = send_request(action, data)
            throw :tokenex_invalid_token unless is_valid_response(response) 
            
            return response['Success']
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
        
        def is_valid_response(response)
            return !response['Success'].nil? && response['Success'] === true
        end
        
    end
end