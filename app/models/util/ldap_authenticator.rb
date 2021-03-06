#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.


class LdapAuthenticator
  # Performs a login over LDAP with the passed data.
  # Returns the logged-in Employee or nil if the login failed.
  def login(username, pwd)
    return nil if Settings.ldap.connection.host.blank?

    if !username.strip.empty? &&
       (auth_user(Settings.ldap.user_dn, username, pwd) ||
        (auth_user(Settings.ldap.external_dn, username, pwd) && group_member(username)))
      Employee.find_by(ldapname: username)
    end
  end

  def auth_user(dn, username, pwd)
    connection.bind_as(base: dn,
                       filter: "uid=#{username}",
                       password: pwd)
  end

  def group_member(username)
    result = connection.search(base: Settings.ldap.group,
                               filter: Net::LDAP::Filter.eq('memberUid', username))
    !result.empty?
  end

  # Returns a Array of LDAP user information
  def all_users
    connection.search(base: Settings.ldap.user_dn,
                      attributes: %w(uid sn givenname mail))
  end

  private

  def connection
    config = Settings.ldap.connection.to_hash
    config[:encryption] = config[:encryption].to_sym if config[:encryption]
    Net::LDAP.new(config)
  end
end
