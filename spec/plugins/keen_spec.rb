require 'spec_helper'
require 'plugins/keen'

describe Pushover::Keen do
  describe '#initialize' do
    it 'should remember the block' do
      empty_proc = Proc.new {}
      step = Pushover::Keen.new('one', &empty_proc)
      step.block.should == empty_proc
    end
  end

  describe '#configure' do
    it 'should set params for each' do

      step = Pushover::Keen.new('one') do
        event_collection 'signups'
        analysis_type 'count'
        timeframe 'last_3_days'
        target_property 'trinkets'
        group_by 'referer'
        interval 'hourly'
        filters [{ :property_value => 'referer',
                   :operator => 'ne',
                   :property_value => 'yahoo.com' }]
        steps [{ :event_collection => 'signups',
                 :actor_property => 'user.id' }]
        analyses [{ :analysis_type => 'count' }]
      end

      step.configure

      step._event_collection.should == 'signups'
      step._analysis_type.should == 'count'
      step._timeframe.should == 'last_3_days'
      step._group_by.should == 'referer'
      step._interval.should == 'hourly'
      step._steps.should == [{
         :event_collection => 'signups',
         :actor_property => 'user.id'
        }]
      step._analyses.should == [{ :analysis_type => 'count' }]
    end
  end

  describe '#run' do
    it 'should run the query based on the analysis type' do
      Keen.stub(:count).with('signups', {
          :timeframe => 'last_3_days'
      }).and_return(365)

      step = Pushover::Keen.new('one') do
        event_collection 'signups'
        analysis_type 'count'
        timeframe 'last_3_days'
      end
      response = step.run
      response.should == 365
    end
  end

  describe '#to_analysis_options' do
    it 'should include various options' do
      step = Pushover::Keen.new('one') do end
      step._timeframe = 'last_4_days'
      step._group_by = 'referer'
      step._target_property = 'trinkets'
      step._interval = 'hourly'
      step._filters = [{ :property_value => 'referer',
                         :operator => 'ne',
                         :property_value => 'yahoo.com' }]
      step._steps = [{ :event_collection => 'signups',
                       :actor_property => 'user.id' }]
      step._analyses = [{ :analysis_type => 'count' }]
      step.to_analysis_options.should == {
          :timeframe => 'last_4_days',
          :target_property => 'trinkets',
          :group_by => 'referer',
          :interval => 'hourly',
          :filters => [{ :property_value => 'referer',
                         :operator => 'ne',
                         :property_value => 'yahoo.com' }],
          :steps => [{ :event_collection => 'signups',
                       :actor_property => 'user.id' }],
          :analyses => [{ :analysis_type => 'count' }]
      }
    end

    it 'should not include nils' do
      step = Pushover::Keen.new('one') do end
      step.to_analysis_options.should == {}
    end
  end
end