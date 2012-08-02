#--
# Config Agents Framework
#
# Copyright (C) 2012 Novell, Inc.
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

module ConfigAgent
  module Constant
    AGENTS_LOGDIR = '/var/log/config_agents'
    AGENTS_LOGFILE = 'services.log'

    LENSES_DIR = '/usr/share/augeas/lenses/'
  end
end
