DEFAULT_ROLE_NAME           = 'Normal User'

PATH_FORMATS = {  GroupType.name  => [:group_type],
                  Group.name      => [:group, :group_type],
                  Incident.name   => [:incident],
                  Tag.name        => [:tag],
                  Update.name     => [:update, :incident],
                  User.name       => [:user] }.freeze

