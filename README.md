# Tweets By X

Tweets By X is a very basic iOS app that shows the tweets of any Twitter user.

##### Default values:
 - Tweet Load Page Size = 10
 - Default User = @FlohNetwork

##### Dependencies (Cocoapods):
 - Kingfisher - Image Download/Cache

##### Notes:

If you wish to change the user whose tweets are being shown, go to `Constants.swift`, and in `line 15` configure the appropriate twitter handle without the @ symbol. You can also change the default page size in `line 16`.

MVVM Design pattern used. Completely done on a single UIViewController with a UITableView.

Please refer to the comments for further help.

##### Known Issues!

  - Not an effective implementation for handling OAuth authentication tokens as there is no check for token expiry/invalidation and renewal logic.
  - API Key and Secret added for demo. TODO: remove later.

Reach out to mohonish.c@gmail.com for feedback/questions/support.
