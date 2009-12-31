DEFAULT_ROLE_NAME           = 'Normal User'

PATH_FORMATS = {  Admin.name      => [:admin],
                  GroupType.name  => [:group_type, :instance],
                  Group.name      => [:group, :group_type, :instance],
                  Incident.name   => [:incident, :instance],
                  Tag.name        => [:tag, :instance],
                  Update.name     => [:update, :incident, :instance],
                  User.name       => [:user, :instance] }.freeze

