####################################################
#
# Set the needed ChefDK environment variables
#
####################################################

$env:CHEFDK_HOME = "C:\Users\Scott\.chefdk"

####################################################
#
#                   NOTES:
#
# The following command 'used' to be required
# before starting to use the docker environments:
#
# --------------------------------------------------
#   chef shell-init powershell | Invoke-Expression
# --------------------------------------------------
#
# As of 21-Aug-2018 the main applications have been
# converted over to the DOCKER environment projects.
#
# These required that C:\opscode\chefdk\embedded\bin
# was NOT listed as the first path entry.
#  - As they wanted to use the following core files
#    from the C:\Program Files\Git\usr\bin\ path:
#     - git
#     - cut
#     - make
#
# However Ruby, Bundler, IRB and the other ruby
# commands still needed to be brought in from:
#   C:\opscode\chefdk\embedded\bin
#
# Resolution:
#   1.) Make sure ALL Docker Paths are listed
#       BEFORE Git and ChefDk
#       within the 'Path' Envirnment Variable.
#   2.) Make sure ALL Git Paths are listed Next
#       (After Docker and Before ChefDk).
#   3.) Make sure that the following ChefDk
#       Paths are listed AFTER Docket and Git:
#       - C:\Users\Scott\.chefdk\gem\ruby\2.4.0\bin
#       - C:\opscode\chefdk\bin\
#       - C:\opscode\chefdk\embedded\bin\
#