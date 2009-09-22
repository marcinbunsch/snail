require 'spec'
require File.dirname(__FILE__) + '/../lib/helpers'

describe Helpers do
  include Helpers

  describe '#table' do
    
    before(:each) do
      @collection = [
        {:name => 'Foo', :email => 'foo@example.com', :id => 11},
        {:name => 'Boo', :email => 'Boo@example.com', :id => 34}
      ]
    end
    
    it 'should render table with no columns' do
      result = table(@collection)
      result.include?('<tr><th>name</th><th>email</th><th>id</th></tr>').should == true
      result.include?('<tr><td>Foo</td><td>foo@example.com</td><td>11</td><tr>').should == true
    end
    
    it 'should render table with a block' do
      result =  table(@collection) { |item| 'copy'  }
      result.include?('<tr><th>name</th><th>email</th><th>id</th><th>options</th></tr>').should == true
      result.include?('<tr><td>Foo</td><td>foo@example.com</td><td>11</td><td>copy</td><tr>').should == true
    end
    
    it 'should render table with columns and block' do
      result =  table(@collection, :name, :email) { |item| 'copy'  }
    end
    
  end
end