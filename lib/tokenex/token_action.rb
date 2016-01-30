module Tokenex
  # http://docs.tokenex.com/#appendix-token-schemes
  TOKEN_ACTION = {
    Tokenize: {
        Name: 'Tokenize',
        Key: 'Token'
    },
    TokenizeFromEncryptedValue: {
        Name: 'TokenizeFromEncryptedValue',
        Key: 'Token'
    },
    ValidateToken: {
        Name: 'ValidateToken',
        Key: 'Valid'
    },
    Detokenize: {
        Name: 'Detokenize',
        Key: 'Value'
    },
    DeleteToken: {
        Name: 'DeleteToken',
        Key: 'Success'
    }
  }
end
