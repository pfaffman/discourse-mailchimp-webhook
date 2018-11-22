# name: discourse-mailchimp-webhook
# version: 0.1
# authors: Jay Pfaffman (jay@literatecomputing.com) and Angus McLeod

PLUGIN_NAME = 'discourse_mailchimp_webhook'.freeze

enabled_site_setting :discourse_mailchimp_webhook_enabled


after_initialize do
  register_seedfu_fixtures(Rails.root.join("plugins", "discourse-mailchimp-webhook", "db", "fixtures").to_s)

  load File.expand_path('../serializers/mailchimp_serializer.rb', __FILE__)

  DiscourseEvent.on(:user_created) do |user|
    WebHook.enqueue_object_hooks(:user_created, user, 'user_created', MailchimpSerializer)
  end

  Plugin::Filter.register(:after_build_web_hook_body) do |context, body|
    body['user_created'].each do |param, value|
      body[param] = value
    end
    
    body
  end
end
