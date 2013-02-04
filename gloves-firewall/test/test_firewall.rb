#--
# Gloves SuSEfirewall2 Library
#
# Copyright (C) 2011 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 or version 3 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++

$LOAD_PATH << File.join(File.dirname(__FILE__),'..')
require "rubygems"
require "mocha"
require 'augeas'
require "test/unit"
require "glove/susefirewall2"
require "config_agent/susefirewall2"

class TestFirewall < Test::Unit::TestCase
  FIREWALL  = { "FW_IGNORE_FW_BROADCAST_EXT"=>"yes", "FW_KERNEL_SECURITY"=>"yes", "FW_SERVICES_REJECT_EXT"=>"0/0,tcp,113",
                "FW_SERVICES_DMZ_UDP"=>"", "FW_SERVICES_DMZ_TCP"=>"", "FW_NOMASQ_NETS"=>"", "FW_MASQ_DEV"=>"zone:ext",
                "FW_IPSEC_TRUST"=>"no", "FW_IPv6"=>"", "FW_LOG_ACCEPT_ALL"=>"no", "FW_TRUSTED_NETS"=>"",
                "FW_SERVICES_INT_IP"=>"", "FW_SERVICES_DMZ_IP"=>"", "FW_SERVICES_ACCEPT_INT"=>"", "FW_LOG"=>"",
                "FW_CONFIGURATIONS_EXT"=>"", "FW_PROTECT_FROM_INT"=>"no", "FW_MASQUERADE"=>"no", "FW_DEV_EXT"=>"any eth0",
                "FW_ALLOW_FW_BROADCAST_EXT"=>"no", "FW_LOG_DROP_CRIT"=>"yes", "FW_REDIRECT"=>"", "FW_FORWARD_DROP"=>"",
                "FW_SERVICES_ACCEPT_DMZ"=>"", "FW_USE_IPTABLES_BATCH"=>"", "FW_IPv6_REJECT_OUTGOING"=>"", "FW_REJECT"=>"",
                "FW_CUSTOMRULES"=>"", "FW_IGNORE_FW_BROADCAST_INT"=>"no", "FW_ALLOW_PING_EXT"=>"no", "FW_SERVICES_INT_RPC"=>"",
                "FW_SERVICES_DMZ_RPC"=>"", "FW_SERVICES_EXT_IP"=>"", "FW_ALLOW_FW_SOURCEQUENCH"=>"", "FW_FORWARD"=>"",
                "FW_CONFIGURATIONS_INT"=>"", "FW_SERVICES_EXT_UDP"=>"", "FW_SERVICES_EXT_TCP"=>"22 80 443 ", "FW_DEV_INT"=>"",
                "FW_IGNORE_FW_BROADCAST_DMZ"=>"no", "FW_STOP_KEEP_ROUTING_STATE"=>"no", "FW_LOG_DROP_ALL"=>"no",
                "FW_SERVICES_DROP_EXT"=>"", "FW_ZONES"=>"", "FW_HTB_TUNE_DEV"=>"", "FW_ALLOW_CLASS_ROUTING"=>"",
                "FW_ALLOW_FW_BROADCAST_INT"=>"no", "FW_CONFIGURATIONS_DMZ"=>"", "FW_DEV_DMZ"=>"", "FW_ALLOW_PING_FW"=>"yes",
                "FW_FORWARD_MASQ"=>"", "FW_REJECT_INT"=>"yes", "FW_ALLOW_FW_BROADCAST_DMZ"=>"no", "FW_LOG_LIMIT"=>"",
                "FW_FORWARD_REJECT"=>"", "FW_ALLOW_INCOMING_HIGHPORTS_UDP"=>"", "FW_ALLOW_INCOMING_HIGHPORTS_TCP"=>"",
                "FW_SERVICES_ACCEPT_EXT"=>"", "FW_SERVICES_EXT_RPC"=>"", "FW_ROUTE"=>"no", "FW_LOAD_MODULES"=>"",
                "FW_ALLOW_PING_DMZ"=>"no", "FW_LOG_ACCEPT_CRIT"=>"yes", "FW_SERVICES_INT_UDP"=>"", "FW_SERVICES_INT_TCP"=>"",
                "FW_MASQ_NETS"=>"0/0"}

  GENERIC_SUCCESS = { "success" => true }

  def setup
    ConfigAgent::Susefirewall2.stubs(:read).returns  FIREWALL
    ConfigAgent::Susefirewall2.stubs(:write).returns GENERIC_SUCCESS
  end

  def teardown
    Mocha::Mockery.instance.stubba.unstub_all
  end

  # Generic read
  def test_read
    firewall = Glove::Susefirewall2.read({})
    assert_equal "any eth0", firewall["FW_DEV_EXT"]
  end

  # Read with unknown kind
  def test_read_syntax_error
    assert_raise NotImplementedError do
      firewall = Glove::Susefirewall2.read({"kind" => "unknown kind"})
    end
  end

  # Read interface from zone
  def test_read_interface
    firewall = Glove::Susefirewall2.read({"kind" => "interface", "interface" => "eth0", "zone" => "EXT"})
    assert_equal "eth0", firewall["interface"], firewall.inspect

    firewall = Glove::Susefirewall2.read({"kind" => "interface", "interface" => "eth5", "zone" => "EXT"})
    assert_equal nil, firewall, firewall.inspect
  end

  # Read open port from zone
  def test_read_port
    firewall = Glove::Susefirewall2.read({"kind" => "open_port", "port" => "22", "zone" => "EXT", "protocol" => "TCP"})
    assert_equal "22", firewall["port"], firewall.inspect

    firewall = Glove::Susefirewall2.read({"kind" => "open_port", "port" => "888", "zone" => "EXT", "protocol" => "TCP"})
    assert_equal nil, firewall, firewall.inspect
  end

  # Add new open port
  def test_add_open_port
    firewall = Glove::Susefirewall2::add({}, {"kind" => "open_port", "port" => "335", "protocol" => "TCP", "zone" => "EXT"})
    assert_equal GENERIC_SUCCESS, firewall
  end

  # Remove open port
  def test_remove_open_port
    firewall = Glove::Susefirewall2::add({}, {"kind" => "open_port", "port" => "22", "protocol" => "TCP", "zone" => "EXT"})
    assert_equal GENERIC_SUCCESS, firewall

    firewall = Glove::Susefirewall2::add({}, {"kind" => "open_port", "port" => "any_port", "protocol" => "TCP", "zone" => "EXT"})
    assert_equal GENERIC_SUCCESS, firewall
  end

  # Add interface to zone
  def test_add_interface
    firewall = Glove::Susefirewall2::add({}, {"kind" => "interface", "interface" => "eth4", "zone" => "EXT"})
    assert_equal GENERIC_SUCCESS, firewall
  end

  # Remove interface from zone
  def test_remove_interface
    firewall = Glove::Susefirewall2::add({}, {"kind" => "interface", "interface" => "eth0", "zone" => "EXT"})
    assert_equal GENERIC_SUCCESS, firewall

    firewall = Glove::Susefirewall2::add({}, {"kind" => "interface", "interface" => "any_interface", "zone" => "EXT"})
    assert_equal GENERIC_SUCCESS, firewall
  end

end
