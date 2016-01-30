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

        def token_from_ccnum(ccnum, token_scheme = TOKEN_SCHEME[:TOKENfour])
            catch (:tokenex_cannot_tokenize_data) do
                return tokenize(ccnum, token_scheme)
            end
            throw :tokenex_invalid_ccnum
        end

        def tokenize(data, token_scheme = TOKEN_SCHEME[:GUID])
            action = "Tokenize"
            request_parameters = {
                "Data" => data,
                "TokenScheme" => token_scheme
            }

            response = send_request(action, request_parameters)
            throw :tokenex_cannot_tokenize_data unless is_valid_response(response)

            response['Token']
        end

        def tokenize_from_encrypted_value(encrypted_data, token_scheme)
            action = "TokenizeFromEncryptedValue"
            request_parameters = {
                "EcryptedData" => encrypted_data,
                "TokenScheme" => token_scheme
            }

            response = send_request(action, request_parameters)
            throw :tokenex_cannot_tokenize_from_encrypted_value unless is_valid_response(response)

            response['Token']
        end

        def detokenize(token)
            action = "Detokenize"
            request_parameters = {
                "Token" => token
            }

            response = send_request(action, request_parameters)
            throw :tokenex_invalid_token unless is_valid_response(response)

            response['Value']
        end

        def validate_token(token)
            action = "ValidateToken"
            request_parameters = {
                "Token" => token
            }

            response = send_request(action, request_parameters)
            throw :tokenex_invalid_token unless is_valid_response(response)

            response['Valid']
        end

        def delete_token(token)
            action = "DeleteToken"
            request_parameters = {
                "Token" => token
            }

            response = send_request(action, request_parameters)
            throw :tokenex_invalid_token unless is_valid_response(response)

            response['Success']
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

            request_array
        end

        def send_request(action, data)
            request_body = build_request_array(data).to_json

            uri = URI.parse("#{@api_base_url}#{action}")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER

            request = Net::HTTP::Post.new(uri, initheader = headers)
            request.body = request_body
            response = http.request(request)
            JSON.parse(response.body)
        end

        def is_valid_response(response)
            !response['Success'].nil? && response['Success'] == true
        end

    end
end
