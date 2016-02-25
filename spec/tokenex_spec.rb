require 'spec_helper'

describe Tokenex do
  def tokenex
    api_base_url = ENV['TOKENEX_API_BASE_URL']
    token_ex_id = ENV['TOKENEX_ID']
    api_key = ENV['TOKENEX_API_KEY']
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

  def valid_success_response(tokenizer)
    expect(tokenizer.error).to be nil
    expect(tokenizer.reference_number).not_to be nil
  end

  def valid_error_response(tokenizer)
    expect(tokenizer.error[:code]).not_to be nil
    expect(tokenizer.error[:code]).to be_an(Integer)
    expect(tokenizer.error[:message]).not_to be nil
    expect(tokenizer.error[:message]).to be_a(String)
    expect(tokenizer.reference_number).not_to be nil
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
      expect(Tokenex::TOKEN_ACTION[:Tokenize][:Name]).to eq('Tokenize')
      expect(Tokenex::TOKEN_ACTION[:Tokenize][:Key]).to eq('Token')

      expect(Tokenex::TOKEN_ACTION[:TokenizeFromEncryptedValue][:Name]).to eq('TokenizeFromEncryptedValue')
      expect(Tokenex::TOKEN_ACTION[:TokenizeFromEncryptedValue][:Key]).to eq('Token')

      expect(Tokenex::TOKEN_ACTION[:ValidateToken][:Name]).to eq('ValidateToken')
      expect(Tokenex::TOKEN_ACTION[:ValidateToken][:Key]).to eq('Valid')

      expect(Tokenex::TOKEN_ACTION[:Detokenize][:Name]).to eq('Detokenize')
      expect(Tokenex::TOKEN_ACTION[:Detokenize][:Key]).to eq('Value')

      expect(Tokenex::TOKEN_ACTION[:DeleteToken][:Name]).to eq('DeleteToken')
      expect(Tokenex::TOKEN_ACTION[:DeleteToken][:Key]).to eq('Success')
  end

  it 'has correct params' do
      expect(Tokenex::REQUEST_PARAMS[:APIKey]).to eq('APIKey')
      expect(Tokenex::REQUEST_PARAMS[:Data]).to eq('Data')
      expect(Tokenex::REQUEST_PARAMS[:EncryptedData]).to eq('EcryptedData')
      expect(Tokenex::REQUEST_PARAMS[:Token]).to eq('Token')
      expect(Tokenex::REQUEST_PARAMS[:TokenExID]).to eq('TokenExID')
      expect(Tokenex::REQUEST_PARAMS[:TokenScheme]).to eq('TokenScheme')

      expect(Tokenex::RESPONSE_PARAMS[:Token]).to eq('Token')
      expect(Tokenex::RESPONSE_PARAMS[:Success]).to eq('Success')
      expect(Tokenex::RESPONSE_PARAMS[:ReferenceNumber]).to eq('ReferenceNumber')
      expect(Tokenex::RESPONSE_PARAMS[:Error]).to eq('Error')
      expect(Tokenex::RESPONSE_PARAMS[:Valid]).to eq('Valid')
      expect(Tokenex::RESPONSE_PARAMS[:Value]).to eq('Value')
  end

  it 'tokenizes a valid credit card' do
    tokenizer = tokenex
    token = tokenizer.tokenize(valid_ccnum)
    valid_success_response(tokenizer)

    ccnum = tokenizer.detokenize(token)
    expect(ccnum).to eq(valid_ccnum.to_s)
    valid_success_response(tokenizer)

    expect(tokenizer.delete_token(token)).to be true
    valid_success_response(tokenizer)
  end

  it 'handles bad credit cards' do
    tokenizer = tokenex
    expect { tokenizer.token_from_ccnum(invalid_ccnum) }.to throw_symbol(:tokenex_invalid_ccnum)
    valid_error_response(tokenizer)
  end

  it 'handles bad tokens' do
    tokenizer = tokenex
    expect { tokenizer.detokenize(invalid_token) }.to throw_symbol(:tokenex_invalid_token)
    valid_error_response(tokenizer)
  end

  it 'can verify a token exists' do
    tokenizer = tokenex
    token = tokenizer.token_from_ccnum(valid_ccnum)
    expect(tokenizer.validate_token(token)).to be true
    valid_success_response(tokenizer)
    tokenizer.delete_token(token)
  end

  it 'can verify a token does not exist' do
    tokenizer = tokenex
    expect(tokenizer.validate_token(invalid_token)).to be false
    valid_success_response(tokenizer)
  end

  it 'can delete a token' do
    tokenizer = tokenex
    token = tokenizer.token_from_ccnum(valid_ccnum)
    expect(tokenizer.validate_token(token)).to be true
    expect(tokenizer.delete_token(token)).to be true
    expect(tokenizer.validate_token(token)).to be false
    valid_success_response(tokenizer)
  end

  it 'will not delete a token that does not exist' do
    tokenizer = tokenex
    expect(tokenizer.validate_token(invalid_token)).to be false
    expect { tokenizer.delete_token(invalid_token) }.to throw_symbol(:tokenex_invalid_token)
    valid_error_response(tokenizer)
  end

  it 'can tokenize arbitrary data' do
    tokenizer = tokenex
    data = 'This is my string with 3 numbers less than 10'
    token = tokenizer.tokenize(data, Tokenex::TOKEN_SCHEME[:GUID])
    expect(tokenizer.validate_token(token)).to be true
    data_detokenized = tokenizer.detokenize(token)
    expect(data_detokenized).to eq(data)
    valid_success_response(tokenizer)
  end

  it 'can tokenize from an encrypted value' do
    tokenizer = tokenex
    encrypted_value = 'FWOd2HUAI+AYfaC3PKAz4dugByBdd+fEAzFfg/G41UuM8yFK23qoq8oD6CURF5WZpXPXySYbN8XvRM6Pd8dfQCTcSQdGiSBfD+Csv39XbOS/laAIekYsPav/eAnY+tNAV7sGUvtqOnDDr0H9W6Q8Z6nqL0rdezCIDY7DuNcOUZxPsv4EV2djG75c9oXI7rPUa/CtIxp1GOCkPYhkV4pv6sxoYOBAJ2KrMDgzlZS9UWQE5x346Jc8ixEOA0bWItTcXUW8/hITYAlM1mTKqRX/Er7Mag2uBrpNM/t5HNtw/zVNgwc8S4ltvm7ow3IG98K2cDpEi16ly2QuMiL5Iq8ghw=='
    token = tokenizer.tokenize_from_encrypted_value(encrypted_value, Tokenex::TOKEN_SCHEME[:sixTOKENfour])
    expect(tokenizer.validate_token(token)).to be true
    valid_success_response(tokenizer)

    data_from_token = tokenizer.detokenize(token)
    expect(data_from_token).to eq(valid_ccnum.to_s)
    valid_success_response(tokenizer)

    expect(tokenizer.delete_token(token)).to be true
    valid_success_response(tokenizer)
  end

end
