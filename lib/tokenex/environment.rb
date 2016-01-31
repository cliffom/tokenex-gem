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
            action = TOKEN_ACTION[:Tokenize]
            request_parameters = {
                "Data" => data,
                "TokenScheme" => token_scheme
            }

            catch (:tokenex_invalid_response) do
                return send_request(action, request_parameters)
            end
            throw :tokenex_cannot_tokenize_data
        end

        def tokenize_from_encrypted_value(encrypted_data, token_scheme)
            action = TOKEN_ACTION[:TokenizeFromEncryptedValue]
            request_parameters = {
                "EcryptedData" => encrypted_data,
                "TokenScheme" => token_scheme
            }

            catch (:tokenex_invalid_response) do
                return send_request(action, request_parameters)
            end
            throw :tokenex_cannot_tokenize_from_encrypted_value
        end

        def detokenize(token)
            action = TOKEN_ACTION[:Detokenize]
            request_parameters = {
                "Token" => token
            }

            catch (:tokenex_invalid_response) do
                return send_request(action, request_parameters)
            end
            throw :tokenex_invalid_token
        end

        def validate_token(token)
            action = TOKEN_ACTION[:ValidateToken]
            request_parameters = {
                "Token" => token
            }

            catch (:tokenex_invalid_response) do
                return send_request(action, request_parameters)
            end
            throw :tokenex_invalid_token
        end

        def delete_token(token)
            action = TOKEN_ACTION[:DeleteToken]
            request_parameters = {
                "Token" => token
            }

            catch (:tokenex_invalid_response) do
                return send_request(action, request_parameters)
            end
            throw :tokenex_invalid_token
        end

        private
        def headers
            {
                'Content-Type' => 'application/json',
                'Accept' => 'application/json'
            }
        end

        def request(data)
            {
                "APIKey" => @api_key,
                "TokenExID" => @tokenex_id
            }.merge(data)
        end

        def send_request(action, data)
            uri = URI.parse("#{@api_base_url}#{action[:Name]}")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER

            request = Net::HTTP::Post.new(uri, initheader = headers)
            request.body = request(data).to_json
            response = http.request(request)
            return_data = JSON.parse(response.body)
            throw :tokenex_invalid_response unless is_valid_response(return_data)

            return_data[action[:Key]]
        end

        def is_valid_response(response)
            !response['Success'].nil? && response['Success'] == true
        end

    end
end
