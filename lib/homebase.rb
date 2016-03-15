require 'json'
require 'ipaddr'
require 'net/http'
require_relative 'homebase/version'

class Homebase
  API_PREFIX = 'https://api.digitalocean.com/v2'
  PUBLIC_IP_URI = URI('https://api.ipify.org/?format=text')
  DOMAIN_RECORDS_FORMAT = "#{API_PREFIX}/domains/%<domain_name>s/records"
  DOMAIN_RECORD_FORMAT =
    "#{API_PREFIX}/domains/%<domain_name>s/records/%<record_id>d"

  class Error < StandardError; end
  class RequestError < Error; end
  class ParseError < Error; end

  def public_ip(opts = {})
    return @public_ip if @public_ip && !opts[:force]
    res = Net::HTTP.get_response(PUBLIC_IP_URI)
    raise(RequestError, "Invalid IP response #{res.code}",
          caller) if res.code != '200'
    ip = res.body.strip
    begin
      IPAddr.new(ip)
    rescue IPAddr::InvalidAddressError
      raise ParseError, 'Invalid Public IP', caller
    end
    @public_ip = ip
  end

  def get_record_by_name(domain_name, record_name, token)
    uri = URI(DOMAIN_RECORDS_FORMAT % {domain_name: domain_name})

    req = Net::HTTP::Get.new(uri)
    req['Content-Type'] = 'application/json'
    req['Authorization'] = "Bearer #{token}"
    body = Net::HTTP.start(uri.host, uri.port,
                           use_ssl: uri.scheme == 'https') do |http|
      res = http.request req
      raise RequestError, "Error - #{res.code}", caller if res.code != '200'
      res.body
    end
    begin
      records = JSON.parse(body, symbolize_names: true)[:domain_records]
    rescue JSON::ParserError
      raise ParseError, 'Invalid JSON Response', caller
    end
    records.find { |record| record[:name] == record_name }
  end

  def update_record(domain_name, record_id, data, token)
    uri = URI(DOMAIN_RECORD_FORMAT % {domain_name: domain_name,
                                      record_id: record_id})
    req = Net::HTTP::Put.new(uri)
    req['Content-Type'] = 'application/json'
    req['Authorization'] = "Bearer #{token}"
    req.body = { data: data }.to_json
    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: uri.scheme == 'https') do |http|
      res = http.request req
      raise RequestError, "Error - #{res.code}", caller if res.code != '200'
      res
    end
  end

  def update_record_with_public_ip(domain_name, record_name, token)
    record = get_record_by_name(domain_name, record_name, token)
    result = update_record(domain_name, record[:id], public_ip, token)
    { result: result, ip: public_ip }
  end
end
