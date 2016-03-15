require 'homebase'

describe Homebase do
  let(:homebase) { Homebase.new }
  let(:domain) { 'example.com' }
  let(:token) { 'b7d03a6947b217efb6f3ec3bd3504582' }
  let(:record_name) { 'boomstick' }
  let(:data) { '5.6.7.8' }
  let(:public_ip) { '5.6.7.8' }
  let(:record_id) { 3352896 }
  let(:success_body) do
    {
      domain_records: [
        {
          id: 3352895,
          type: 'A',
          name: 'necronomicon',
          data: '6.6.6.6',
          priority: nil,
          port: nil,
          weight: nil
        },
        {
          id: 3352896,
          type: 'A',
          name: 'boomstick',
          data: '1.2.3.4',
          priority: nil,
          port: nil,
          weight: nil
        }
      ],
      links: {},
      meta: {total: 2}
    }
  end
  let(:forbidden_body) do
    {
      id: 'forbidden',
      message:  'You do not have access for the attempted action.'
    }
  end

  it 'has a version number' do
    expect(Homebase::VERSION).not_to be_nil
  end

  describe '.public_ip' do
    let(:response) { instance_double(Net::HTTPResponse) }

    it 'should return public ip' do
      expect(response).to receive(:body).and_return(public_ip)
      expect(response).to receive(:code).and_return('200')
      expect(Net::HTTP).to receive(:get_response).with(Homebase::PUBLIC_IP_URI)
        .and_return(response)
      expect(homebase.public_ip).to eql public_ip
    end

    it 'should raise an exception if bad response from server' do
      expect(response).to receive(:code).twice.and_return('500')
      expect(Net::HTTP).to receive(:get_response).and_return(response)
      expect { homebase.public_ip }.to raise_error(Homebase::RequestError)
    end

    it 'should raise an exception if the response is not a valid IP address' do
      expect(response).to receive(:body).and_return('666.666.666.666')
      expect(response).to receive(:code).and_return('200')
      expect(Net::HTTP).to receive(:get_response).with(Homebase::PUBLIC_IP_URI)
        .and_return(response)
      expect { homebase.public_ip }.to raise_error(Homebase::ParseError)
    end
  end

  describe '.get_records' do
    let(:response) do
      response = instance_double(Net::HTTPResponse)
      http = instance_double(Net::HTTP)
      expect(http).to receive(:request).and_return(response)
      expect(Net::HTTP).to receive(:start).and_yield(http)
      response
    end

    it 'should return the matching record' do
      expect(response).to receive(:body).and_return(success_body.to_json)
      expect(response).to receive(:code).and_return('200')
      expect(homebase.get_record_by_name(domain, record_name, token))
        .to eql success_body[:domain_records][1]
    end

    it 'should raise an exception if response status is not 200' do
      allow(response).to receive(:body).and_return(forbidden_body.to_json)
      expect(response).to receive(:code).twice.and_return('403')
      expect { homebase.get_record_by_name(domain, record_name, token) }
        .to raise_error(Homebase::RequestError)
    end

    it 'should raise an exception if response is not json' do
      expect(response).to receive(:body).and_return('invalid json')
      expect(response).to receive(:code).and_return('200')
      expect { homebase.get_record_by_name(domain, record_name, token) }
        .to raise_error(Homebase::ParseError)
    end
  end

  describe '.update_record' do
    it 'should change ip value for a record' do
      res = instance_double(Net::HTTPResponse)
      http = instance_double(Net::HTTP)
      expect(res).to receive(:code).and_return('200')
      expect(http).to receive(:request) do |req|
        expect(req.body).to eql({data: data}.to_json)
        expect(req.method).to eql 'PUT'
        res
      end

      expect(Net::HTTP).to receive(:start).and_yield(http)
      homebase.update_record(domain, record_id, data, token)
    end
  end

  describe '.update_record_with_public_ip' do
    it 'should update a record with the public ip' do
      expect(homebase).to receive(:public_ip).twice.and_return(public_ip)
      expect(homebase).to receive(:get_record_by_name)
        .with(domain, record_name, token)
        .and_return(success_body[:domain_records][1])
      expect(homebase).to receive(:update_record)
        .with(domain, record_id, public_ip, token)
      homebase.update_record_with_public_ip(domain, record_name, token)
    end
  end
end
