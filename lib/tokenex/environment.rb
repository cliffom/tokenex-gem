module Tokenex
    class Environment
    
        def initialize(tokenex_id, api_key, options={})
            @tokenex_id = tokenex_id
            @api_key = api_key
        end
        
        def token_from_ccnum(ccNum)
            return ccNum
        end
        
        def ccnum_from_token(token)
            return token
        end

    end
end