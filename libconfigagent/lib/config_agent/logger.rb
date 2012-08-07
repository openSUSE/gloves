#--
# Config Agents Framework
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

require "logger"
require "fileutils"

module ConfigAgent
  # provides unified logging mechanism
  module Logger
    AGENTS_LOGDIR = '/var/log/config_agents'
    AGENTS_LOGFILE = 'services.log'

    # logger object
    #
    # ensures that logging directory exists
    # @todo log rotation
    #   Logger don't support log rotation yet, so it can be added
    # @return [Logger] instance of logger
    def log
      if !@log_instance
        FileUtils.mkdir_p(AGENTS_LOGDIR) unless File.exist?(AGENTS_LOGDIR)
        @log_instance ||= ::Logger.new(File.join(AGENTS_LOGDIR, AGENTS_LOGFILE)) # no log rotation yet
      end
      @log_instance
    end

    # automatically include these methods also to class methods
    # when included in a class (auto extend the class)
    def self.included(base)
      base.extend(self)
    end
  end
end
