require 'spec_helper'

describe Tokenex do
  def tokenex
    api_base_url = ENV["TOKENEX_API_BASE_URL"]
    token_ex_id = ENV["TOKENEX_ID"]
    api_key = ENV["TOKENEX_API_KEY"]
    Tokenex::Environment.new(api_base_url, token_ex_id, api_key)
  end
  
  def input_ccnum
    4242424242424242
  end
  
  def token
    tokenex.token_from_ccnum(input_ccnum)
  end
  
  def ccnum
    tokenex.ccnum_from_token(token['Token'])
  end

  it 'has a version number' do
    expect(Tokenex::VERSION).not_to be nil
  end

  it 'tokenizes a credit card' do
    expect(token['Token']).not_to be nil
    expect(token['Success']).to be true
  end
  
  it 'detokenizes a credit card' do
    expect(ccnum['Value']).not_to be nil
    expect(token['Success']).to be true
  end
  
  it 'returns valid data' do
    expect(input_ccnum === ccnum['Value'].to_i).to be true
  end
end
