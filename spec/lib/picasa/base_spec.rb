require 'spec_helper'

describe Picasa::Base do
  subject { Picasa::Base.new }
  describe '#http_request' do
    it 'raises with protected method' do
      expect { subject.http_request }.to raise_error(NoMethodError)
    end
    it 'raises with ArgumentError' do
      expect { subject.send(:http_request, :nomethod) }.to raise_error(ArgumentError)
    end
    it 'raises with PicasaUnknownHTTPRequest' do
      expect { subject.send(:http_request, :nomethod, 'http') }.to raise_error(Picasa::PicasaUnknownHTTPRequest)
    end
    it 'sends get request' do
      Net::HTTP.any_instance.should_receive(:get)
      subject.send(:http_request, :get, 'http')
    end
    it 'sends post request' do
      Net::HTTP.any_instance.should_receive(:post)
      subject.send(:http_request, :post, 'http')
    end
  end
end
