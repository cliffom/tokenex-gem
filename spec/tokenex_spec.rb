require 'spec_helper'

describe Tokenex do
  def tokenex
    api_base_url = ENV["TOKENEX_API_BASE_URL"]
    token_ex_id = ENV["TOKENEX_ID"]
    api_key = ENV["TOKENEX_API_KEY"]
    Tokenex::Environment.new(api_base_url, token_ex_id, api_key)
  end

  def valid_ccnum
    4242424242424242
  end

  def invalid_ccnum
    1234567812345678
  end

  def invalid_token
    'abcdefg'
  end

  def token
    tokenex.token_from_ccnum(valid_ccnum)
  end

  def ccnum
    tokenex.detokenize(token)
  end

  it 'has a version number' do
    expect(Tokenex::VERSION).not_to be nil
  end

  it 'has token actions' do
      expect(Tokenex::TOKEN_ACTION).not_to be nil
  end

  it 'has token schemes' do
    expect(Tokenex::TOKEN_SCHEME).not_to be nil
  end

  it 'has correct action mappings' do
      expect(Tokenex::TOKEN_ACTION[:Tokenize]).to eq('Tokenize')
      expect(Tokenex::TOKEN_ACTION[:TokenizeFromEncryptedValue]).to eq('TokenizeFromEncryptedValue')
      expect(Tokenex::TOKEN_ACTION[:ValidateToken]).to eq('ValidateToken')
      expect(Tokenex::TOKEN_ACTION[:Detokenize]).to eq('Detokenize')
      expect(Tokenex::TOKEN_ACTION[:DeleteToken]).to eq('DeleteToken')
  end

  it 'tokenizes a credit card' do
    expect(token).not_to be nil
  end

  it 'detokenizes a credit card' do
    expect(ccnum).not_to be nil
  end

  it 'returns valid data' do
    expect(valid_ccnum === ccnum.to_i).to be true
  end

  it 'handles bad credit cards' do
    expect { tokenex.token_from_ccnum(invalid_ccnum) }.to throw_symbol(:tokenex_invalid_ccnum)
  end

  it 'handles bad tokens' do
    expect { tokenex.detokenize(invalid_token) }.to throw_symbol(:tokenex_invalid_token)
  end

  it 'can verify a token exists' do
    expect(tokenex.validate_token(token)).to be true
  end

  it 'can verify a token does not exist' do
    expect(tokenex.validate_token(invalid_token)).to be false
  end

  it 'can delete a token' do
    token_to_delete = token
    expect(tokenex.validate_token(token_to_delete)).to be true
    expect(tokenex.delete_token(token)).to be true
    expect(tokenex.validate_token(token_to_delete)).to be false
  end

  it 'will not delete a token that does not exist' do
    expect(tokenex.validate_token(invalid_token)).to be false
    expect { tokenex.delete_token(invalid_token) }.to throw_symbol(:tokenex_invalid_token)
  end

  it 'can tokenize arbitrary data' do
    data = "This is my string with 3 numbers less than 10"
    token = tokenex.tokenize(data, Tokenex::TOKEN_SCHEME[:GUID])
    expect(tokenex.validate_token(token)).to be true
    data_detokenized = tokenex.detokenize(token)
    expect(data_detokenized).to eq(data)

  end

  it 'can tokenize from an encrypted value' do
      encrypted_value = "FWOd2HUAI+AYfaC3PKAz4dugByBdd+fEAzFfg/G41UuM8yFK23qoq8oD6CURF5WZpXPXySYbN8XvRM6Pd8dfQCTcSQdGiSBfD+Csv39XbOS/laAIekYsPav/eAnY+tNAV7sGUvtqOnDDr0H9W6Q8Z6nqL0rdezCIDY7DuNcOUZxPsv4EV2djG75c9oXI7rPUa/CtIxp1GOCkPYhkV4pv6sxoYOBAJ2KrMDgzlZS9UWQE5x346Jc8ixEOA0bWItTcXUW8/hITYAlM1mTKqRX/Er7Mag2uBrpNM/t5HNtw/zVNgwc8S4ltvm7ow3IG98K2cDpEi16ly2QuMiL5Iq8ghw=="
      token = tokenex.tokenize_from_encrypted_value(encrypted_value, Tokenex::TOKEN_SCHEME[:sixTokenfour]);
      expect(tokenex.validate_token(token)).to be true
      data_from_token = tokenex.detokenize(token)
      expect(data_from_token).to eq(valid_ccnum.to_s)
      expect(tokenex.delete_token(token)).to be true
  end

end
