#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/diff'
require 'puppet/util/execution'
require 'tempfile'

describe Puppet::Util::Diff do
  describe ".diff" do
    it "should execute the diff command with arguments" do
      Puppet[:diff] = 'foo'
      Puppet[:diff_args] = 'bar'

      Puppet::Util::Execution.expects(:execute).with(['foo', 'bar', 'a', 'b'], {:failonfail => false, :combine => false}).returns('baz')
      subject.diff('a', 'b').should == 'baz'
    end

    it "should omit diff arguments if none are specified" do
      Puppet[:diff] = 'foo'
      Puppet[:diff_args] = ''

      Puppet::Util::Execution.expects(:execute).with(['foo', 'a', 'b'], {:failonfail => false, :combine => false}).returns('baz')
      subject.diff('a', 'b').should == 'baz'
    end

    it "should return empty string if the diff command is empty" do
      Puppet[:diff] = ''

      Puppet::Util::Execution.expects(:execute).never
      subject.diff('a', 'b').should == ''
    end

    it "should correctly diff files without arguments" do
      Puppet[:diff] = 'diff'
      tempfileA = Tempfile.new("puppet-diffingA")
      tempfileB = Tempfile.new("puppet-diffingB")
      tempfileA.open
      tempfileB.open
      tempfileA.print "hello\n"
      tempfileB.print "world\n"
      tempfileA.close
      tempfileB.close
      subject.diff(tempfileA.path, tempfileB.path).should include("@@ -1 +1 @@\n-hello\n\+world\n")
      tempfileA.delete
      tempfileB.delete
    end

    it "should correctly diff files with an argument" do
      Puppet[:diff] = 'diff'
      Puppet[:diff_args] = '-u'
      tempfileA = Tempfile.new("puppet-diffingA")
      tempfileB = Tempfile.new("puppet-diffingB")
      tempfileA.open
      tempfileB.open
      tempfileA.print "hello\n"
      tempfileB.print "world\n"
      tempfileA.close
      tempfileB.close
      subject.diff(tempfileA.path, tempfileB.path).should include("@@ -1 +1 @@\n-hello\n\+world\n")
      tempfileA.delete
      tempfileB.delete
    end

    it "should correctly diff files with multiple arguments" do
      Puppet[:diff] = 'diff'
      Puppet[:diff_args] = '-u --strip-trailing-cr'
      tempfileA = Tempfile.new("puppet-diffingA")
      tempfileB = Tempfile.new("puppet-diffingB")
      tempfileA.open
      tempfileB.open
      tempfileA.print "hello\n"
      tempfileB.print "world\n"
      tempfileA.close
      tempfileB.close
      subject.diff(tempfileA.path, tempfileB.path).should include("@@ -1 +1 @@\n-hello\n\+world\n")
      tempfileA.delete
      tempfileB.delete
    end
  end
end
