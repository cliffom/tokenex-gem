require "json"
require "net/https"
require "uri"

module Tokenex
    class Environment
        attr_reader :error, :reference_number

        def initialize(api_base_url, tokenex_id, api_key, proxy_url = '', options={})
            @api_base_url = api_base_url
            @tokenex_id = tokenex_id
            @api_key = api_key
            @proxy_url = proxy_url
        end

        def token_from_ccnum(ccnum, token_scheme = TOKEN_SCHEME[:TOKENfour])
            catch (:tokenex_cannot_tokenize_data) do
                return tokenize(ccnum, token_scheme)
            end
            throw :tokenex_invalid_ccnum
        end

        def tokenize(data, token_scheme = TOKEN_SCHEME[:GUID])
            request_parameters = {
                REQUEST_PARAMS[:Data] => data,
                REQUEST_PARAMS[:TokenScheme] => token_scheme
            }

            catch (:tokenex_invalid_response) do
                return send_request(TOKEN_ACTION[:Tokenize], request_parameters)
            end
            throw :tokenex_cannot_tokenize_data
        end

        def tokenize_from_encrypted_value(encrypted_data, token_scheme)
            request_parameters = {
                REQUEST_PARAMS[:EncryptedData] => encrypted_data,
                REQUEST_PARAMS[:TokenScheme] => token_scheme
            }

            catch (:tokenex_invalid_response) do
                return send_request(TOKEN_ACTION[:TokenizeFromEncryptedValue], request_parameters)
            end
            throw :tokenex_cannot_tokenize_from_encrypted_value
        end

        def detokenize(token)
            request_parameters = {
                REQUEST_PARAMS[:Token] => token
            }

            catch (:tokenex_invalid_response) do
                return send_request(TOKEN_ACTION[:Detokenize], request_parameters)
            end
            throw :tokenex_invalid_token
        end

        def validate_token(token)
            request_parameters = {
                REQUEST_PARAMS[:Token] => token
            }

            catch (:tokenex_invalid_response) do
                return send_request(TOKEN_ACTION[:ValidateToken], request_parameters)
            end
            throw :tokenex_invalid_token
        end

        def delete_token(token)
            request_parameters = {
                REQUEST_PARAMS[:Token] => token
            }

            catch (:tokenex_invalid_response) do
                return send_request(TOKEN_ACTION[:DeleteToken], request_parameters)
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
                REQUEST_PARAMS[:APIKey] => @api_key,
                REQUEST_PARAMS[:TokenExID] => @tokenex_id
            }.merge(data)
        end

        def send_request(action, data)
            uri = URI.parse("#{@api_base_url}#{action[:Name]}")
            proxy = URI.parse(@proxy_url)
            http = Net::HTTP.new(uri.host, uri.port, proxy.host, proxy.port, proxy.user, proxy.password)
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
            @error = response[RESPONSE_PARAMS[:Error]].empty? ? nil : error_from_response(response[RESPONSE_PARAMS[:Error]])
            @reference_number = response[RESPONSE_PARAMS[:ReferenceNumber]].empty? ? nil : response[RESPONSE_PARAMS[:ReferenceNumber]]
            !response[RESPONSE_PARAMS[:Success]].nil? && response[RESPONSE_PARAMS[:Success]] == true
        end

        def error_from_response(response)
          {
            code: response.split(" : ").first.to_i,
            message: response.split(" : ").last
          }
        end
    end
end
