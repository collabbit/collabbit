SIGNUP_NOTICE               = "Success! There's one more step. You need to check your email for the confirmation link we sent you. Click on that link to continue into Collabbit."
ACCOUNT_SETUP_ERROR         = 'There was an error setting up your account. Try again or <a href="mailto:support@collabbit.org">contact the support team</a>.'
SIGNUP_COMPLETE             = 'Signup complete! Enter your email and password below to join this Collabbit'
MISSING_ACTIVATION_CODE     = 'The activation code was missing. Please follow the URL from your email.'
INVALID_ACTIVATION_CODE     = 'There\'s something wrong with your activation code. Try signing in. If that doesn\'t work, <a href="mailto:support@collabbit.org">contact the support team</a>'
INVALID_EMAIL_OR_PASSWORD   = 'Sorry, you entered an invalid email or password. Please try again.'
INACTIVE_ACCOUNT            = 'Your account is inactive. Please <a href="mailto:support@collabbit.org">contact the support team</a> to reactivate'
UPDATE_CREATED              = 'You successfully added an update'
UPDATE_CREATE_ERROR         = 'Woops! We couldn\'t add that update. Please try again or <a href="mailto:support@collabbit.org">contact the support team</a>.'
GROUP_CREATED               = 'You successfully added a group'
GROUP_CREATE_ERROR          = 'Woops! We couldn\'t add that group. Please try again or <a href="mailto:support@collabbit.org">contact the support team</a>.'
GROUP_TYPE_CREATED          = 'You successfully added a group type'
GROUP_TYPE_CREATE_ERROR     = 'Uh-oh! Something broke when we tried to add that group type. Please try again or <a href="mailto:support@collabbit.org">contact the support team</a>.'
INSTANCE_CREATED            = 'You successfully created an instance. Good Job!'
INSTANCE_CREATE_ERROR       = 'Something went wrong. We couldn\'t create an instance for you. Try again or <a href="mailto:support@collabbit.org">contact the support team</a>.'
INCIDENT_CREATED            = 'You successfully created an incident'
INCIDENT_CREATE_ERROR       = 'Woops! Collabbit couldn\'t create that incident. Please try again or <a href="mailto:support@collabbit.org">contact the support team</a>.'
PRIVILEGE_CREATED           = 'You successfully added a privledge'
PRIVILEGE_CREATE_ERROR      = 'Woops! We couldn\'t add that priveledge. Please try again or <a href="mailto:support@collabbit.org">contact the support team</a>.'
PRIVILEGE_UPDATED           = 'You successfully updated that privledge'
PRIVILEGE_UPDATE_ERROR      = 'Woops! We couldn\'t update that priveledge. Please try again or <a href="mailto:support@collabbit.org">contact the support team</a>.'
USER_UPDATED                = 'Success! User has been updated.'
USER_UPDATE_ERROR           = 'Oh no! There was an error updating the user. Please try again or <a href="mailto:support@collabbit.org">contact the support team</a>.'
GROUP_UPDATED               = 'You successfully updated that group'
GROUP_UPDATE_ERROR          = 'Oh no! There was an error updating the group. Please try again or <a href="mailto:support@collabbit.org">contact the support team</a>.'
UPDATE_UPDATED              = 'You successfully modified that update'
UPDATE_UPDATE_ERROR         = 'Woops! We couldn\'t modify that update. Please try again or <a href="mailto:support@collabbit.org">contact the support team</a>.'
GROUP_TYPE_UPDATED          = 'You updated that group successfully'
GROUP_TYPE_UPDATE_ERROR     = 'Woops! We couldn\'t update that group type. Please try again or <a href="mailto:support@collabbit.org">contact the support team</a>.'
INCIDENT_UPDATED            = 'You updated that incident successfully'
INCIDENT_UPDATE_ERROR       = 'Woops! We couldn\'t update that incident. Please try again or <a href="mailto:support@collabbit.org">contact the support team</a>.'
ROLE_UPDATED                = 'Good! You updated the role successfully'
ROLE_UPDATE_ERROR           = 'Woops! We couldn\'t update that role. Please try again or <a href="mailto:support@collabbit.org">contact the support team</a>.'
INSTANCE_UPDATED            = 'You successfully updated that instance'
INSTANCE_UPDATE_ERROR       = 'Uh-oh! Instance failed to update. Please try again or <a href="mailto:support@collabbit.org">contact the support team</a>.'
DEFAULT_ROLE_NAME           = 'Normal User'
PASSWORD_RESET              = 'We reset your password and sent it to your email. Check your email (including the spam folder) to retrieve your new password.'
TAG_DESTROYED               = 'The tag was safely deleted.'

PATH_FORMATS = {  Admin.name      => [:admin],
                  GroupType.name  => [:group_type, :instance],
                  Group.name      => [:group, :group_type, :instance],
                  Incident.name   => [:incident, :instance],
                  Tag.name        => [:tag, :instance],
                  Update.name     => [:update, :incident, :instance],
                  User.name       => [:user, :instance] }.freeze