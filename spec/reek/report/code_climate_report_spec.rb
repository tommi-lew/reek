require_relative '../../spec_helper'
require_lib 'reek/examiner'
require_lib 'reek/report/report'
require_lib 'reek/report/formatter'

require 'json'
require 'stringio'

RSpec.describe Reek::Report::CodeClimateReport do
  let(:options) { {} }
  let(:instance) { Reek::Report::CodeClimateReport.new(options) }
  let(:examiner) { Reek::Examiner.new(source) }

  before do
    instance.add_examiner examiner
  end

  context 'with empty source' do
    let(:source) { '' }

    it 'prints empty json' do
      expect { instance.show }.to output(/^\[\]$/).to_stdout
    end
  end

  context 'with smelly source' do
    let(:source) { 'def simple(a) a[3] end' }

    it 'prints smells as json' do
      out = StringIO.new
      instance.show(out)
      out.rewind
      result = JSON.parse(out.read)
      expected = JSON.parse <<-EOS
        [
          {
            "type": "issue",
            "check_name": "LowCohesion/UtilityFunction",
            "description": "simple doesn't depend on instance state (maybe move it to another class?)",
            "categories": ["Complexity"],
            "location": {
              "path": "string",
              "lines": {
                "begin": 1,
                "end": 1
              }
            }
          },
          {
            "type": "issue",
            "check_name": "UncommunicativeName/UncommunicativeParameterName",
            "description": "simple has the parameter name 'a'",
            "categories": ["Complexity"],
            "location": {
              "path": "string",
              "lines": {
                "begin": 1,
                "end": 1
              }
            }
          }
        ]
      EOS

      expect(result).to eq expected
    end
  end
end
