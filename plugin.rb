# name: discourse-mailchimp-webhook
# version: 0.1
# authors: Jay Pfaffman (jay@literatecomputing.com) and Angus McCload

# based on stuff I got here:  https://meta.discourse.org/t/setting-up-webhooks/49045
# and here: https://meta.discourse.org/t/how-to-add-new-webhooks-and-customize-webhook-payload/59609

PLUGIN_NAME = 'discourse_mailchimp_webhook'.freeze

enabled_site_setting :discourse_mailchimp_webhook_enabled


after_initialize do

  register_seedfu_fixtures(Rails.root.join("plugins", "discourse-mailchimp-webhook", "db", "fixtures").to_s)


  DiscourseEvent.on(:user_created) do |user|
    WebHook.enqueue_object_hooks(:user, user, 'user_created')
  end

end
