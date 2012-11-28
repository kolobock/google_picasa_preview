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

  describe '.entries' do
    subject { Picasa::Base }
    it 'raises with ArgumentError' do
      expect { subject.entries }.to raise_error(ArgumentError)
    end
    context 'parse xml' do
      let(:xml1) { '<feed><totalResults>1</totalResults><entry>1</entry></feed>' }
      let(:xml2) { '<feed><totalResults>2</totalResults><entry>1</entry><entry>2</entry></feed>' }
      it 'parses xml' do
        XmlSimple.should_receive(:xml_in) { 'xml' }
        subject.entries('<feed/>')
      end
      it { subject.entries('<feed/>').should == [] }
      it { subject.entries(xml1).should have(1).item }
      it { subject.entries(xml2).should have(2).items }
    end
  end
end
